# Task 1 - Numbers

## Objective

Starting from an array of integers, the goal is to keep the ones that simultaneously respect two rules:
- they are even numbers
- they are not powers of 2

The function that needs to be implemented has the following header:
```c
void remove_numbers(int *a, int n, int *target, int *ptr_len);
```

**The first argument** (`a`) is a list of 32-bit numbers.

**The second argument** (`n`) represents the number of elements in the original array.

**The third argument** (`target`) represents the memory address where the function should write the result after removing the unwanted numbers. 
Thus, after completing the two subtasks, `target` will contain the new array with only the accepted numbers.

**The fourth argument** (`ptr_len`) represents the memory address where the function must write the number of elements in the newly created array.

## Running the Program

- A Makefile with the `build`, `run` and `clean` rules is provided
- Edit the `checker.c` file, declaring an array for testing (or use the default one)
- From the terminal, enter `make run` and inspect the output
