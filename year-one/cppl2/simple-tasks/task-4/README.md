# Task 4 - Sudoku

## Objective

The goal of this task is running a full check of a 9x9 Sudoku board: each line and column of the big square, 
but also each of the nine smaller boxes. This will be done using three functions:

- `int check_row(char* sudoku, int row)`
- `int check_column(char* sudoku, int column)`
- `int check_box(char* sudoku, int box)`

The sudoku board is given as an 81-long char array, and the other three arguments represent which row, column, or box to check as an integer between 0 and 8.
The sudoku board may contain numbers which are not the digits 1-9.

The checker will call these 3 functions and will print the results.
The first line in the output is the `check_row` results with `row` going from 0 to 8 in that order.
The second line are the results of `check_column` and the third of `check_box`.

>**Note:** The value `1` means CORRECT, whereas `2` means WRONG.

## Running the Program
- A Makefile with the `build`, `run` and `clean` rules is provided
- Edit the `checker.c` file, declaring a sudoku board for testing (or use the default one)
- From the terminal, enter `make run` and inspect the output
