# Task 4 - Composite Palindrome

## Objective

Starting from an array of words, the goal is to find the longest palindrom that can be formed using a subset of words from the array.
In case of finding two or more such palindromes of maximum length, the **lexicographically smallest** one will be chosen.

The first implemented function has the following header:
```c
const int check_palindrome(const char *str, const int len);
```

**The first argument** (`str`) represents the string that is being checked.

**The second argument** (`len`) represents the length of the string.

> **Important:** The function returns **0** if the string is not a palindrome and **1** otherwise.

The second implemented function has the following header:
```c
const char* composite_palindrome(const char **strs, const int len);
```

**The first argument** (`strs`) represents the array of words.

**The second argument** (`len`) represents the length of the array.

> **Important:** The function creates a copy of the result in the heap section and returns it.

## Running the Program

- A Makefile with the `build`, `run` and `clean` rules is provided
- Edit the `checker.c` file, declaring the array of words for testing (or use the default one)
- From the terminal, enter `make run` and inspect the output
