# Data Structures and Algorithms
# C Satellite Network

## Table of Contents
- [Overview](#overview)
- [Network Base Input and Output](#network-base-input-and-output)
- [Base Tasks](#base-tasks)
- [Complex Task](#complex-task)
- [Running the Program](#running-the-program)
- [Final Notes](#final-notes)

## Overview

This project models a network of satellites as a **binary tree**, where satellites are interconnected through direct communication links.
A **root satellite**, positioned closest to Earth’s atmosphere, serves as the communication hub for all other satellites in the network.
The network supports basic and simplified operations, such as printing the layout of the binary tree level by level, identifying transmission sources based on encoded sequences and finding the closest satellite to two or more other satellites. The network also features an extension of the initial model: a **multi tree** root can be attached to any initial node from the initial binary tree and the distance between any two nodes can be calculated by the program.

### Communication Frequency & Positioning

Each satellite is uniquely defined by its name. From a functional point of view, every satellite has a **reporting frequency**,
which indicates how often it transmits data. To optimise communication:

- Satellites that report **more frequently** are placed **closer to Earth** (closer to the root).
- Satellites with **lower frequencies** are positioned **farther away** in the binary tree.
- Each connection between two satellites has a **fixed distance K**.

To achieve this structure, **intermediate (linking) satellites** may be introduced. These are not primary satellites but serve to maintain the binary tree structure and ensure network connectivity.

### Binary Tree Construction Rules

To build the tree, the following process is applied iteratively:

1. Identify the two satellites with the **lowest reporting frequencies**.
2. Create a new link satellite as their **parent**:
   - Its frequency is the **sum** of the two children’s frequencies.
   - Its name is the **concatenation** of the left child’s name and the right child’s name.
3. Insert this new satellite into a **Min-Heap** based on frequency.
4. Repeat the process until all satellites are connected under a single binary tree structure.

## Network Base Input and Output

Running the program requires three command line arguments to be passed to the binary file:

1. `-c<x>`, where `<x>` is a number between 1 and 5 which represents the task that will be completed
2. `input_file_name`
3. `output_file_name`

For ease and consistency with the Makefile included in the project, the two files will be located in the working
directory and will have specific names.

### Input File: `tema2.in`

Each task that the program can perform first requires providing the necessary data to build the binary tree as described in the previous section. This information must be found at the beginning of a file named `tema2.in` found in the working directory.
Any input required by the tasks will be added after these essential lines. The format is as follows:

1. **First line:**
   An integer `N` representing the number of primary satellites in the network
2. **Next N lines:**
   Separated by exactly one space, the reporting frequency and name of the satellites
   > Important: The name of each primary satellite cannot exceed 16 characters

### Output File: `tema2.out`

Similarly, the working directory must also contain a file named `tema2.out` to be used for the program's output.
This file will only contain the output of the requested operation, not errors.

### Error Handling

Any attempt to run the program with less than three arguments or invalid file names will exit the process with code 1
and print a proper message to stdout (not the output file). Certain operations that may not work properly with wrong input
will check the results of auxiliary functions before advancing.

## Base Tasks

The implemented program can handle simple tasks such as building and printing the binary tree as a routine check and tracking down satellites
based on a codified message. Each of these operations requires a properly built binary tree beforehand, respecting the above criteria. This part of
the implementation was handled separately before undertaking the actual tasks. 
Below are the four possible basic operations for this satellite network:

### Printing

Displays the satellites in the binary tree level by level, starting from the root and using breadth-first traversal. 
For every satellite, prints the two identifiers in this format: `<frequency>-<name>`. Each level will be printed on one line.
This operation does not require extra information about the network.

### Message Source Identification

The space agency receives messages from one or more satellites, with the source(s) codified as a bitstring. 
The program finds the source(s) of each message, using the following rules:
- Each **`0`** in the bitstring represents a **left move** in the binary tree
- Each **`1`** in the bitstring represents a **right move** in the binary tree
- If a leaf is encountered when tracking down the source of a signal and the code is not over,
  the corresponding satellite is the first source. The other(s) can be found by resuming the search from the root.

For each decoded bitstring, the program prints on the same line the names of found source satellites, separated by one space.

Required input for this operation (appended to the `tema2.in` file):

1. **First added line:**
   An integer `N` representing the number of codes transmitted to the space agency
2. **Next N added lines:**
   The bitstrings that represent the codes 
   > Important: The length of each bitstring cannot exceed 1000 digits

### Message Encoding

The space agency has to answer back to several satellites in the network, first determining the bitstring codification of the destination.
Using the rules from the previous operation, the program finds the encodings of the destination satellites and concatenates them into the final code.
The result is then printed on one line.

Required input for this operation (appended to the `tema2.in` file):

1. **First added line:**
   An integer `N` representing the number of satellites the space agency is transmitting the message to
2. **Next N added lines:**
   The names of the destination satellites

### Finding the Lowest Common Ancestor

In order to maintain the network, it is necessary to find the closest common ancestor of two or more satellites undergoing maintenance.
Once the sought satellite is found, its name must be printed.

Required input for this operation (appended to the `tema2.in` file):

1. **First added line:**
   An integer `N` representing the number of satellites in maintenance
2. **Next N added lines:**
   The names of the satellites in maintenance

## Complex Task

After the success of the initial satellite network, the space agency has decided to expand the main binary network. 
The extension introduces **multi trees** attached to nodes in the main binary tree (except the root). 
Each node in the main tree may now hold an additional reference to the **root of a multi tree**. Nodes in these subtrees 
are similar to main tree nodes: they also store a **reporting frequency** and a **name**.
Given this complex new feature, the program supports two more operations:

1. **Attaching subtrees** to the appropriate node in the main binary tree
2. **Computing the distance** between **any two nodes**, regardless of whether they belong to:
   - the main tree
   - the same multi tree
   - different multi trees
   - a combination of the above

> **Note:** Each connection between satellites is considered to have a **unit distance** of 1.

Only the calculated distance is printed, without having to reprint the layout of the new satellite network.

Required input for this operation (appended to the `tema2.in` file):

1. **First added line:**
   An integer `T` representing the number of multi trees that will be attached
2. **First 2 added lines for every multi tree:**
   The name of the satellite from the initial tree that will connect to the multi tree
   The reporting frequency and the name of the multi tree root, separated by one space
3. **Next added line:**
   An integer `P` representing the number of parent nodes in the multi tree
4. **First added line for every parent:**
   The reporting frequency and the name of the parent node, separated by one space
5. **Next added line:**
   An integer `C` representing the number of children that the parent has
6. **Next C added lines:**
   The reporting frequency and name of every child, separated by one space
7. **Final added line:**
   The names of the two satellites the distance of which must be determined within the extended network

## Running the Program

- A simple Makefile is provided, containing the `build` and `clean` rules, alongside the 5 variations of the `run` rule
- Ensure that the working directory has two files named `tema2.in` and `tema2.out`
- The file `tema2.in` should contain the right input for the task that needs to be completed
- From the terminal, use the command `make run<x>`, where you replace `<x>` with the number of the desired task
- Inspect the output in `tema2.out`

## Final Notes

- For memory safety, the program has been analysed using Valgrind, fixing all occuring errors
