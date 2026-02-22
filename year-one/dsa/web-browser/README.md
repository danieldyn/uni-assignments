# Data Structures and Algorithms 
# C Web Browser with Tabs and History

## Table of Contents
- [Overview](#overview)
- [Components](#components)
- [Tasks](#tasks)
- [Input and Output](#input-and-output)
- [Running the Program](#running-the-program)
- [Final Notes](#final-notes)

## Overview

This project simulates the architecture of a simplified **web browser**, inspired by the behaviour of modern browsers. The goal is to build a C application that:
- supports navigation between web pages
- manages **multiple tabs** simultaneously
- maintains **independent browsing history** for each tab

## Components

### Web Page

A web page is represented using a structure that includes:
- `ID` — an integer identifier
- `URL` — a string of up to 50 characters
- `description` — a variable-length string ending with a newline (`\n`)

Each time a new tab is created, a **default page** is loaded, always containing:
- `ID: 0`
- `URL: https://acs.pub.ro/`
- `Description: Computer Science`

### Web Tab

A tab is defined by a structure that contains:
- a **unique ID**
- a pointer to the **current web page**
- two stacks to manage navigation history:
  - `BACKWARD` — holds pages visited before the current page
  - `FORWARD` — holds pages visited after going back

All tabs are managed using a **circular doubly linked list with a sentinel node**.
A pointer to the **currently active tab** is maintained to ensure easier interaction for basic operations in the browser.

### Web Browser

The browser is the main structure and includes:
- a list of all tabs
- a pointer to the currently active tab
- functionality for:
  - opening new tabs
  - switching between tabs
  - visiting new pages
  - navigating backward and forward in history

At startup, the browser contains a **default tab** (`ID: 0`) that loads the **default page**.

## Tasks

The implemented program can handle several tasks to manage the browsing history of each tab.
Below are the possible operations with their aim, restrictions and exceptional cases:

### NEW_TAB
- Creates a new tab and adds it to the tabs list
- The new tab is initialised with the default page and set as the **current tab**
- The new tab is appended at the end of the tabs list and assigned an ID by incrementing the last tab's ID

> **Note:** last tab's ID refers to the ID of the last **inserted** tab in the list, not the last tab still active.

### CLOSE
- Closes the current tab by removing it from the tabs list
- After closing, the tab to the **left** of the closed tab becomes the current tab
- The tab with ID `0` (the initial tab) **cannot** be closed. Attempting to do so should display an error message

### OPEN <ID>
- Switches the current tab to the tab with the specified `<ID>`
- If no tab with the given ID exists, display an error message

### NEXT
- Switches the current tab to the next tab in the tabs list
- The newly opened tab becomes the current tab

### PREV
- Switches the current tab to the previous tab in the tabs list
- The newly opened tab becomes the current tab

### PAGE <ID>
- Opens the page with the specified `<ID>` in the current tab
- If the page does not exist, display an error message
- The current page before opening the new page is pushed onto the **backward** stack
- The **forward** stack is cleared

### BACKWARD
- Navigates to the last page in the **backward** stack of the current tab
- If the stack is empty, display an error message
- The current page before navigating backward is pushed onto the **forward** stack

### FORWARD
- Navigates to the last page in the **forward** stack of the current tab
- If the stack is empty, display an error message
- The current page before navigating forward is pushed onto the **backward** stack

### PRINT
- Prints all open tab IDs in a single line, separated by spaces
- The listing starts from the current tab and continues circularly to the right
- Prints on a new line the description of the current page in the current tab

### PRINT_HISTORY <ID>
- Prints the URLs of the pages visited in the tab with the specified `<ID>`, each on a new line
- If the tab does not exist, display the error message
- The order of URLs printed is:
  1. Pages in the **forward** stack (from the oldest to the newest)
  2. The current page
  3. Pages in the **backward** stack (from the newest to the oldest)

### Error Handling

- The error message `"403 Forbidden"` must be displayed for the exceptional cases in operations
`CLOSE`, `OPEN <ID>`, `PAGE <ID>`, `BACKWARD`, and `FORWARD`, when invalid operations are attempted
- In case an invalid operation name is provided, a different error message will be printed, highlighting the wrong command

## Input and Output

The program uses two files for input and output, both of which need to have a specific name.

### Input File: `tema1.in`

The program reads data from the file `tema1.in`, structured as follows:

1. **First line:**  
   An integer `P` representing the number of web pages available for testing (excluding the default page).

2. **Next 3 × P lines:**  
   For each page:
   - Line 1: Page `ID` (integer, must be different from `0`)
   - Line 2: Page `URL` (max 50 characters)
   - Line 3: Page `description` (string ending with a newline)

> **Note:** The default page (ID `0`) is **not** included in the input file and is initialised in the program.

3. **Next line:**  
   An integer `N` representing the number of operations to be executed.

4. **Following N lines:**  
   Each line contains one operation command as described in the previous section.

### Output File: `tema1.out`

The results of the commands (e.g., from `PRINT`, `PRINT_HISTORY`, or error messages) will be written to `tema1.out` in the order in which the commands are processed.

## Running the Program

- A simple Makefile is provided, containing the `build`, `run` and `clean` rules
- Ensure that the working directory has two files named `tema1.in` and `tema1.out`
- The file `tema1.in` should contain the aforementioned information
- From the terminal, use the command `make && make run`
- Inspect the output in `tema1.out`

## Final Notes

- The program has been run for many edge cases and complex tests of as many as 1000 operations
- For memory safety, the program has been analysed using Valgrind, fixing all occuring errors
