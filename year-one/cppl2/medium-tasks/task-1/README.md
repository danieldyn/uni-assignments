# Task 1 - List Sorting

## Objective

Starting from a simple linked list containing integers, the goal is to sort them in ascending order without swapping the nodes in memory 
(only by updating the fields of the structs).

The structure of a node is:
```
struct node {
    int val;
    struct node* next;
};
```
and, initially, the `next` field is set to `NULL` for all nodes in the list.

The function that needs to be implemented has the following header:
```c
struct node* sort(int n, struct node* node);
```

**The first argument** (`n`) represents the number of nodes in the list.

**The second argument** (`node`) is a linked list of n 32-bit integers.

> **Important:** Overall, the list contains consecutive values starting from 1.

## Example

Before sorting:

| Address    | Value     | Next      |
| ---------  | --------- | --------- |
| 0x32       | 2         | NULL      |
| 0x3A       | 1         | NULL      |
| 0x42       | 3         | NULL      |

The `sort` function returns the address of the first node in the sorted list:

| Address    | Value     | Next      |
| ---------  | --------- | --------- |
| 0x32       | 2         | 0x42      |
| 0x3A       | 1         | 0x32      |
| 0x42       | 3         | NULL      |

## Running the Program

- A Makefile with the `build`, `run` and `clean` rules is provided
- Edit the `checker.c` file, declaring a list for testing (or use the default one)
- From the terminal, enter `make run` and inspect the output
