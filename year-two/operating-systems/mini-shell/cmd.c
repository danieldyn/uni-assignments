// SPDX-License-Identifier: BSD-3-Clause

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>

#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "cmd.h"
#include "utils.h"

#define READ		0
#define WRITE		1
#define EXEC_ERROR  127

/**
 * Internal change-directory command.
 */
static bool shell_cd(word_t *dir)
{
	int argc = 0;
	char *target_dir = NULL;
	char working_dir[BUFSIZ];
	word_t *literals = dir;

	// String literal list parsing
	while (literals != NULL) {
		argc++;
		if (argc == 1)
			target_dir = get_word(literals);
		literals = literals->next_word;
	}

	// Check: need exactly one argument
	if (argc != 1) {
		if (target_dir != NULL)
			free(target_dir);
		return true;
	}

	if (target_dir[0] != '/') { // Not an absolute path, need to concatenate with pwd
		if (getcwd(working_dir, sizeof(working_dir)) == NULL)
			perror("getcwd");
		target_dir = (char *)realloc(target_dir, (strlen(target_dir) + strlen(working_dir) + 2) * sizeof(char));
		strcat(working_dir, "/");
		strcat(working_dir, target_dir);
		snprintf(target_dir, BUFSIZ, "%s", working_dir);
		//strcpy(target_dir, working_dir); linter warning, but works because of the logic above
	}

	// Perform directory change
	if (chdir(target_dir) < 0) {
		free(target_dir);
		fprintf(stderr, "cd: no such file or directory: %s\n", target_dir);
		return false;
	}

	free(target_dir);

	return true;
}

/**
 * Internal exit/quit command.
 */
static int shell_exit(void)
{
	return SHELL_EXIT;
}

/**
 * Internal print working directory command.
 */
static int shell_pwd(void)
{
	char working_dir[BUFSIZ];

	if (getcwd(working_dir, sizeof(working_dir)) == NULL)
		perror("getcwd");
	else
		fprintf(stdout, "%s\n", working_dir);

	return 0; // To be passed as exit code for the caller
}

/**
 * Perform an assignment like 'key=value', assuming its format was checked.
 */
static int perform_assignment(const char *s)
{
	char *key, *value;

	value = strchr(s, '=') + 1;
	key = (char *)calloc(value - s, sizeof(char));
	if (key == NULL)
		return -1;
	memcpy(key, s, value - s - 1);

	// Perform variable assignment with overwrite option on
	if (setenv(key, value, 1) < 0) {
		fprintf(stderr, "Failed to set variable '%s'\n", key);
		free(key);
		return -1;
	}

	free(key);

	return 0;
}

/**
 * Perform redirections inside a process, looking at "in", "out" and "err".
 * While the children can be allowed to use exit(), the parent process (shell)
 * must not die when having to redirect built-in commands like 'pwd' and 'cd'.
 * Thus, the type parameter will act as a discriminator used by the caller:
 * type == 'p' => parent process, will return from function without dying
 * type == 'c' => child process, will call _exit(EXIT_FAILURE)
 */
static void perform_redirections(simple_command_t *s, char type)
{
	// Sanity checks
	if (s == NULL || strchr("pc", type) == NULL)
		return;

	char *in_file, *out_file, *err_file;
	int new_fd, out_flags = O_WRONLY | O_CREAT;

	// Input redirection
	if (s->in != NULL) {
		in_file = get_word(s->in);

		new_fd = open(in_file, O_RDONLY);
		if (new_fd < 0) {
			perror("open for '<' redirection");
			free(in_file);
			if (type == 'p')
				return;
			_exit(EXIT_FAILURE);
		}

		// Make stdin refer to the new open file structure
		dup2(new_fd, STDIN_FILENO);
		close(new_fd);
		free(in_file);
	}

	// Output and error redirection to the same file
	if (s->out != NULL && s->err != NULL) {
		out_file = get_word(s->out);
		err_file = get_word(s->err);

		if (strcmp(out_file, err_file) == 0) {
			// Check for append mode
			if ((s->io_flags & IO_OUT_APPEND) != 0 && (s->io_flags & IO_ERR_APPEND) != 0)
				out_flags |= O_APPEND;
			else
				out_flags |= O_TRUNC;

			new_fd = open(out_file, out_flags, 0644);
			if (new_fd < 0) {
				perror("open for '2&>' redirection");
				free(err_file);
				if (type == 'p')
					return;
				_exit(EXIT_FAILURE);
			}

			// Make stdout and stderr refer to the new open file structure
			dup2(new_fd, STDOUT_FILENO);
			dup2(new_fd, STDERR_FILENO);
			close(new_fd);
			free(out_file);
			return;
		}

		free(out_file);
		free(err_file);
	}

	// Output redirection
	if (s->out != NULL) {
		out_file = get_word(s->out);

		// Check for append mode
		if ((s->io_flags & IO_OUT_APPEND) != 0)
			out_flags |= O_APPEND;
		else
			out_flags |= O_TRUNC;

		new_fd = open(out_file, out_flags, 0664);
		if (new_fd < 0) {
			perror("open for '>' redirection");
			free(out_file);
			if (type == 'p')
				return;
			_exit(EXIT_FAILURE);
		}

		// Make stdout refer to the new open file structure
		dup2(new_fd, STDOUT_FILENO);
		close(new_fd);
		free(out_file);
	}

	// Error redirection
	if (s->err != NULL) {
		err_file = get_word(s->err);

		// Check for append mode
		if ((s->io_flags & IO_ERR_APPEND) != 0)
			out_flags |= O_APPEND;
		else
			out_flags |= O_TRUNC;

		new_fd = open(err_file, out_flags, 0664);
		if (new_fd < 0) {
			perror("open for '2>' redirection");
			free(err_file);
			if (type == 'p')
				return;
			_exit(EXIT_FAILURE);
		}

		// Make stderr refer to the new open file structure
		dup2(new_fd, STDERR_FILENO);
		close(new_fd);
		free(err_file);
	}
}

/**
 * Parse a simple command (internal, environment variable assignment,
 * external command).
 */
static int parse_simple(simple_command_t *s, int level, command_t *father)
{
	// Sanity checks
	if (s == NULL || s->verb == NULL || s->verb->string == NULL)
		return 0;

	bool boolean_ret;
	int ret, argc = 0, i, status, in_fd, out_fd, err_fd;
	char *p;
	char **argv;
	pid_t pid;

	// Using aux field as a buffer for the command
	s->aux = (char *)get_word(s->verb);
	if (s->aux == NULL)
		return 0;

	/* If builtin command, execute the command. */

	// Shell exit
	if (strcmp(s->aux, "exit") == 0 || strcmp(s->aux, "quit") == 0) {
		free(s->aux);
		return shell_exit();
	}

	// Change directory and print working directory
	if (strcmp(s->aux, "cd") == 0 || strcmp(s->aux, "pwd") == 0) {
		// Save old file descriptors and perform redirections as parent process
		in_fd = dup(STDIN_FILENO);
		out_fd = dup(STDOUT_FILENO);
		err_fd = dup(STDERR_FILENO);
		perform_redirections(s, 'p');

		// Execute the built-in command
		if (strcmp(s->aux, "cd") == 0) {
			boolean_ret = shell_cd(s->params);

			if (boolean_ret == true)
				ret = 0;
			else
				ret = 1;
		} else {
			ret = shell_pwd();
		}
		// Restore old file descriptors for the parent process
		dup2(in_fd, STDIN_FILENO);
		close(in_fd);
		dup2(out_fd, STDOUT_FILENO);
		close(out_fd);
		dup2(err_fd, STDERR_FILENO);
		close(err_fd);

		free(s->aux);
		return ret;
	}

	/* If variable assignment, execute the assignment and return the exit status. */
	p = strchr(s->aux, '=');
	if (p != NULL) {
		// Check for the existence of key and value
		if (p != s->aux && *(p + 1) != '\0') {
			ret = perform_assignment(s->aux);
			free(s->aux);
			return ret;
		}
	}

	/* If external command:
	 *   1. Fork new process
	 *     2c. Perform redirections in child
	 *     3c. Load executable in child
	 *   2. Wait for child
	 *   3. Return exit status
	 */

	argv = get_argv(s, &argc);
	pid = fork();

	switch (pid) {
	case 0:
		// Child process
		perform_redirections(s, 'c');
		execvp(argv[0], argv);

		// This line is reached in case of an execution error
		fprintf(stderr, "Execution failed for '%s'\n", argv[0]);
		_exit(EXEC_ERROR);

	case -1:
		// Error
		perror("fork");

		free(s->aux);
		for (i = 0 ; i < argc; i++)
			free(argv[i]);
		free(argv);

		return -1;

	default:
		// Parent process
		waitpid(pid, &status, 0);

		free(s->aux);
		for (i = 0; i < argc; i++)
			free(argv[i]);
		free(argv);

		if (WIFEXITED(status) == true)
			return WEXITSTATUS(status);

		return -1;
	}
}

/**
 * Process two commands in parallel, by creating two children.
 */
static bool run_in_parallel(command_t *cmd1, command_t *cmd2, int level,
		command_t *father)
{
	int statuses[2], ret;
	pid_t pids[2];

	pids[0] = fork();
	switch (pids[0]) {
	case 0:
		// First child, executing the first command
		ret = parse_command(cmd1, level + 1, father);
		_exit(ret);

	case -1:
		perror("fork");
		return false;

	default:
		break;
	}

	pids[1] = fork();
	switch (pids[1]) {
	case 0:
		// Second child, executing the second command
		ret = parse_command(cmd2, level + 1, father);
		_exit(ret);

	case -1:
		perror("fork");
		return false;

	default:
		break;
	}

	// Wait for the children to die
	waitpid(pids[0], &statuses[0], 0);
	waitpid(pids[1], &statuses[1], 0);

	return (WIFEXITED(statuses[0]) && WEXITSTATUS(statuses[0] == 0) &&
			WIFEXITED(statuses[1]) && WEXITSTATUS(statuses[1] == 0));
}

/**
 * Run commands by creating an anonymous pipe (cmd1 | cmd2).
 */
static bool run_on_pipe(command_t *cmd1, command_t *cmd2, int level,
		command_t *father)
{
	int pipefds[2], ret, statuses[2];
	pid_t pids[2];

	ret = pipe(pipefds);
	if (ret < 0) {
		perror("pipe");
		return false;
	}

	pids[READ] = fork();
	switch (pids[READ]) {
	case 0:
		// Close read end of the pipe and duplicate the writing end
		close(pipefds[READ]);
		dup2(pipefds[WRITE], STDOUT_FILENO);
		close(pipefds[WRITE]);
		ret = parse_command(cmd1, level + 1, father);
		_exit(ret);

	case -1:
		perror("fork");
		return false;

	default:
		break;
	}

	pids[WRITE] = fork();
	switch (pids[WRITE]) {
	case 0:
		// Close write end of the pipe and duplicate the read end
		close(pipefds[WRITE]);
		dup2(pipefds[READ], STDIN_FILENO);
		close(pipefds[READ]);
		ret = parse_command(cmd2, level + 1, father);
		_exit(ret);

	case -1:
		perror("fork");
		return false;

	default:
		break;
	}

	// Close the pipe for the parent
	close(pipefds[READ]);
	close(pipefds[WRITE]);

	// Wait for the children to die
	waitpid(pids[READ], &statuses[READ], 0);
	waitpid(pids[WRITE], &statuses[WRITE], 0);

	return (WIFEXITED(statuses[WRITE]) && WEXITSTATUS(statuses[WRITE]) == 0);
}

/**
 * Parse and execute a command.
 */
int parse_command(command_t *c, int level, command_t *father)
{
	/* Sanity checks */
	if (c == NULL)
		return 0;

	if (c->op == OP_NONE) {
		// scmd != NULL and cmd1 == cmd2 == NULL
		return parse_simple(c->scmd, level, father);
	}

	int ret;
	bool boolean_ret;

	switch (c->op) {
	case OP_SEQUENTIAL:
		// Execute the commands one after the other.
		parse_command(c->cmd1, level + 1, c);
		return parse_command(c->cmd2, level + 1, c);

	case OP_PARALLEL:
		// Execute the commands simultaneously.
		run_in_parallel(c->cmd1, c->cmd2, level + 1, c);
		return 0;

	case OP_CONDITIONAL_NZERO:
		// Execute the second command only if the first one returns non zero
		ret = parse_command(c->cmd1, level + 1, c);

		if (ret != 0)
			return parse_command(c->cmd2, level + 1, c);

		return ret;

	case OP_CONDITIONAL_ZERO:
		// Execute the second command only if the first one returns zero
		ret = parse_command(c->cmd1, level + 1, c);

		if (ret == 0)
			return parse_command(c->cmd2, level + 1, c);

		return ret;

	case OP_PIPE:
		// Redirect the output of the first command to the input of the second.
		boolean_ret = run_on_pipe(c->cmd1, c->cmd2, level + 1, c);

		if (boolean_ret == true)
			return 0;

		return 1;

	default:
		return SHELL_EXIT;
	}
}
