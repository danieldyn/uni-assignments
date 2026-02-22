# Task 3 - Base64

## Objective

Starting from a string with a number of characters that is a **multiple of 3**, the goal is to determine the Base64 encoding of this initial string.
The function that performs this task will have the following header:

```c
    void base64(char *a, int n, char *target, int *ptr_len);
```

**The first argument** is the string on which to apply the encoding algorithm

**The second argument** is the length of the initial string

**The third argument** is the memory address where you will put the new encoded string

**The last argument** represents the memory address where we will store the length of the new encrypted string.

> **Note:** The length of the initial string is a multiple of 3 so that there is no need for padding.

## Running the Program
- A Makefile with the `build`, `run` and `clean` rules is provided
- Edit the `checker.c` file, declaring a string for testing (or use the default one)
- From the terminal, enter `make run` and inspect the output
