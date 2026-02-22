#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Function that prints the pair (operand1, operand2)
void asm_print(char dest, char *src)
{
	// decide on the first operand
	switch (dest) {
		case 'a':
		case 'b':
		case 'c':
		case 'd':
			printf("e%cx, ", dest);
			break;
		default:
			break;
	}

	// decide on the second operand
	switch (src[0]) {
		case 'a':
		case 'b':
		case 'c':
		case 'd':
			printf("e%cx\n", src[0]);
			break;
		default:
			printf("%s\n", src);
	}
}

// Function that prints an operation
void asm_operation(char dest, char *src, char operator)
{
	// decide on the operator
	switch (operator) {
		case '&':
			printf("AND ");
			break;
		case '|':
			printf("OR ");
			break;
		case '^':
			printf("XOR ");
			break;
		case '+':
			printf("ADD ");
			break;
		case '-':
			printf("SUB ");
			break;
		case '<':
			printf("SHL ");
			break;
		case '>':
			printf("SHR ");
			break;
		default:
			printf("MOV ");
			break;
	}

	// print the operands
	asm_print(dest, src);
}

// Function that handles multiplication
void asm_mul(char dest, char *src)
{
	char eax[] = "a";

	// check if eax is the destination
	if (dest == 'a') {
		if (src[0] < 'a')
			printf("MUL %s\n", src);
		else
			asm_print(dest, src);
	}
	else {
		// print mov eax, destination
		asm_operation('a', &dest, 'm');
		
		// apply multiplication
		if (src[0] < 'a')
			printf("MUL %s\n", src);
		else
			printf("MUL e%cx\n", src[0]);
		
		// print mov eax, result
		asm_operation(dest, eax, 'm');
	}
}

// Function that handles division
void asm_div(char dest, char *src)
{
	char eax[] = "a";

	// check for invalid divisor
	if (src[0] == '0')
		printf("Error\n");
	else
	{
		// print mov eax, destination
		asm_operation('a', &dest, 'm');

		// apply division
		if (src[0] < 'a')
			printf("DIV %s\n", src);
		else
			printf("DIV e%sx\n", src);

		// print mov eax, result
		asm_operation(dest, eax, 'm');
	}
}

// Function that handles an instruction
void asm_instruction(char *line)
{
	char op = 'm';   // symbol for MOV

	// check for multiplication and division
	if (strchr(line, '*'))
		asm_mul(line[0], strrchr(line, ' ') + 1);
	
	else if (strchr(line, '/'))
		asm_div(line[0], strrchr(line, ' ') + 1);
		
		else {
			// check if the operation should not be mov
			if (line[6])
				op = line[6];
			
			// print the operation
			asm_operation(line[0], strrchr(line, ' ') + 1, op);
		}
}

// Function that handles cmp
void asm_cmp(char *instr)
{
	printf("CMP ");

	// print the operands for the cmp
	asm_print(instr[0], strrchr(instr, ' ') + 1);

	// decide on the jump
	if (instr[2] == '<') {
		if (instr[3] == '=')
			printf("JG ");
		else
			printf("JGE ");
	} else {
		if (instr[2] == '>')
			if (instr[3] == '=')
				printf("JL ");
			else
				printf("JLE ");
		else
			printf("JNE ");
	}
}

// Function that handles an if instruction
void asm_if(char *line)
{
	char instr[50], *p;

	// extract the instruction within the paranthesis
	p = strchr(line, '(') + 1;
	strcpy(instr, p);

	// start with the cmp
	asm_cmp(instr);
	printf("end_label\n");

	// handle the instructions inside the if one by one
	fgets(line, 50, stdin);
	while (line[0] != '}') {
		// remove newline and '}'
		line[strlen(line) - 2] = '\0';

		// remove indentation
		while (!strchr("abcd", line[0]))
			line++;

		// print the current instruction and move to the next one
		asm_instruction(line);
		fgets(line, 50, stdin);
	}
	
	printf("end_label:\n");
}

// Function that handles a while instruction
void asm_while(char *line)
{
	char instr[50], *p;

	// start label
	printf("start_loop:\n");

	// extract the instruction within the paranthesis
	p = strchr(line, '(') + 1;
	strcpy(instr, p);

	// handle the cmp
	asm_cmp(instr);
	printf("end_label\n");

	// handle the instructions inside the while one by one
	fgets(line, 50, stdin);
	while (line[0] != '}') {
		// remove newline and '}'
		line[strlen(line) - 2] = '\0';

		// remove indentation
		while (!strchr("abcd", line[0]))
			line++;

		// print the current instruction and move to the next one
		asm_instruction(line);
		fgets(line, 50, stdin);
	}

	printf("JMP start_loop\n");
	printf("end_label:\n");
}

// Function that handles the for instruction
void asm_for(char *line)
{
	char instr[50], *p;
	int pos;

	// extract the first instruction within the paranthesis
	p = strchr(line, '(') + 1;
	strcpy(instr, p);
	pos = strchr(instr, ';') - instr;
	instr[pos] = '\0';

	// print the first instruction
	asm_instruction(instr);
	printf("start_loop:\n");

	// extract the second instruction within the paranthesis
	p = strchr(line, ';') + 2;
	strcpy(instr, p);
	pos = strchr(instr, ';') - instr;
	instr[pos] = '\0';

	// print the compare instruction
	asm_cmp(instr);
	printf("end_label\n");

	// extract the third instruction within the paranthesis
	p = strrchr(line, ';') + 2;
	strcpy(instr, p);

	// handle the instructions inside the for one by one
	fgets(line, 50, stdin);
	while (line[0] != '}') {
		// remove newline and '}'
		line[strlen(line) - 2] = '\0';

		// remove indentation
		while (!strchr("abcd", line[0]))
			line++;

		// print the current instruction and move to the next one
		asm_instruction(line);
		fgets(line, 50, stdin);
	}

	// print the third instruction within the paranthesis
	asm_instruction(instr);

	printf("JMP start_loop\n");
	printf("end_loop:\n");
}

int main(void)
{
	char line[50];

	// keep reading lines from stdin
	while (fgets(line, 50, stdin)) {
		// remove newline and ';'
		line[strlen(line) - 2] = '\0';

		// check if the operation is a simple instruction or not
		if ('a' <= line[0] && line[0] <= 'd')
			asm_instruction(line);

		else if (line[0] == 'i') {
			// end string at ')'
			line[strlen(line) - 2] = '\0';
			asm_if(line);
		}
		
		else if (line[0] == 'w') {
			// end string at ')'
			line[strlen(line) - 2] = '\0';
			asm_while(line);
		} 
		
		else if (line[0] == 'f') {
			// end string at ')'
			line[strlen(line) - 2] = '\0';
			asm_for(line);
		}
	}
	return 0;
}
