# Task 2 - Word Operations

## Objective

Starting from a text, the goal is to separate it into an array of words and then sort these words by length and lexicographically.

The first implemented function has the following header:
```c
void get_words(char *s, char **words, int number_of_words);
```

**The first argument** (`s`) represents the initial text.

**The second argument** (`words`) is the destination array of words.

**The third argument** (`number_of_words`) is the number of words in the text

The second implemented function has the following header:
```c
void sort(char **words, int number_of_words, int size);
```

**The first argument** (`words`) is the array of words.

**The second argument** (`number_of_words`) is the number of words in the array.

**The third argument** (`size`) is the necessary size to call `qsort`

## Running the Program

- A Makefile with the `build`, `run` and `clean` rules is provided
- Edit the `checker.c` file, declaring a text for testing (or use the default one)
- From the terminal, enter `make run` and inspect the output
