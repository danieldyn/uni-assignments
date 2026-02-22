# Computer Programming and Programming Languages 2 (Hardware Software Interface)
# C to Assembly Transpiler

## Table of Contents

- [Overview](#overview)
- [Conventions](#conventions)
- [Operations](#operations)
- [Running the Program](#running-the-program)

## Overview

The aim of this project is to implement a small transpiler that converts simple C code snippets into basic assembly instructions.
The assignment served as a way of familiarising myself with Assembly language mnemonics and of understanding how high-level constructs 
map to low-level operations.

This transpiler is intentionally minimalistic and should be treated as such. Thus, features such as checking
the input before performing any operations are not considered relevant enough for the goal of this project. The translation is 
as simple as possible while covering basic arithmetic operations, register usage, data movement, and control flow constructs. 
The input is guaranteed to be correct with respect to the project's conventions.

## Conventions

- **Basic Register Mapping:**
  - `a` → `eax`
  - `b` → `ebx`
  - `c` → `ecx`
  - `d` → `edx`

- **Data Types**
  - All of the data types are considered to be **4 bytes** (including pointers)
  - Every number will be treated as an **int** (4 bytes), in order to avoid using smaller registers (`al`, `ah`, `ax`, etc.)
  - When performing arithmetic operations, all will be considered on **32 bits** (4 bytes) for consistency

- **Handling Equivalent Instructions**
  - If an instruction has an equivalent, contracted form in C, the more **explicit and simple** one will be used
  - Example: `a = a + 12` will be used instead of `a += 12`
  - This is to avoid overcomplicating the program and defeating the purpose of the project

## Operations

Only the most common operations have been chosen for this project, given its purpose. Each subsection will explain any potential restrictions.
The examples will be given as input versus output, for a better understanding of the implementation decisions made for each section.

### MOV

The `mov` instruction is the simplest of all. As the name says, it moves the data from one place to another.

ASM Syntax: `MOV destination, source`

| **C Code**    | **ASM Code**          |
|------------   |----------------       |
| `a = 1;`      | `MOV eax, 1`          |
| `b = a;`      | `MOV ebx, eax`        |

>**Note:** There will be no `MOV 2, eax` as that is an invalid operation.

### Logical Operations

The three common bitwise logical operations are included.

ASM Syntax: `AND destination, source` | `OR destination, source` | `XOR destination, source`

| **C Code**        | **ASM Code**    |
|------------       |---------------- |
| `a = a & 0xFF;`   | `AND eax, 0xFF` |
| `b = b \| a;`      | `OR ebx, eax`   |
| `c = a ^ c;`      | `XOR ecx, eax`  |

### Shift Operations

The other two bitwise operations can also be used by the program.

ASM Syntax: `SHL destination, num_bits_shifted` | `SHR destination, num_bits_shifted`

| **C Code**        | **ASM Code**    |
|-------------      |---------------- |
| `a = a << 1;`     | `SHL eax, 1`    |
| `b = b >> 2;`     | `SHR ebx, 2`    |

### Arithmetic Operations

The four fundamental arithmetic operations are also included. Given the technical talk required for multiplication and division,
this pair will be treated after the easier one.

#### Addition and Subtraction

The two straightforward arithmetic operations require a register, an assignment operator and the expression to be assigned.
Inputs with the plus and assign (`+=`) operator or similar ones are not taken into consideration here.

ASM Syntax: `ADD destination, source` | `SUB destination, source`

| **C Code**        | **ASM Code**      |
|------------       |----------------   |
| `a = a + 5;`      | `ADD eax, 5`      |
| `b = b - a;`      | `SUB ebx, eax`    |

#### Multiplication and Division

The other two basic arithmetic operations depend very much on data type in Assembly so as to avoid overflows, exception and incorrect results.
For the purpose of this program, only the 32-bit multiplication and division rules will be used, but with a few notes:
- The first factor of the multiplication must be found in the `eax` register
- The second factor can be found in another 32-bit register or can be a number
- The result of the multiplication should be stored in `edx:eax` (high:low); only `eax` will be used this time
- The dividend should be stored in `edx:eax` (high:low); similarly, only `eax` will be used here
- The divisor can be found in a 32-bit register other than `eax`
- Attempting to divide by 0 will result in a **Divide Error** exception

ASM Syntax: `MUL source` | `DIV divisor`

| **C Code**        | **ASM Code**    |
|------------       |---------------- |
| `a = a * 3;`      | `MUL 3`         |
| `b = b * c;`      | `MOV eax, ebx`  |
|                   | `MUL ecx`       |
|                   | `MOV ebx, eax`  |
| `a = a / 3;`      | `MOV eax, a`    |
|                   | `DIV 3`         |
|                   | `MOV a, eax`    |
| `b = b / c;`      | `MOV eax, ebx`  |
|                   | `DIV ecx`       |
|                   | `MOV ebx, eax`  |

### CMP and Jumps

The `cmp` instruction compares two values by subtracting the second operand from the first. 
It updates the CPU flags, but does not store the result. This is useful for conditional statements. 
Using `cmp` and a few jump instructions esentially works like the `if` instruction from C.

ASM Syntax: `CMP operand1, operand2`

Example in ASM syntax:
- `MOV eax, 3`
- `CMP eax, 3` ; Compares eax with 3
- `JE equal_label` ; Jumps to label "equal_label" if eax == 3 (Zero flag is set)

Jumps use labels to control the flow of the program based on certain conditions. Only the most common ones are included 
in this project. Here is a brief description of each included jump instruction:

- **JMP** (Jump): Jumps to the given label.
- **JE** (Jump if Equal): Jumps to the given label if the two compared values are equal (e.g.: `CMP` sets the Zero Flag).
- **JNE** (Jump if Not Equal): Jumps if the two values are not equal (Zero Flag is not set).
- **JG** (Jump if Greater): Jumps if the first value is greater than the second (Signed comparison).
- **JGE** (Jump if Greater or Equal): Jumps if the first value is greater than or equal to the second.
- **JL** (Jump if Less): Jumps if the first value is less than the second.
- **JLE** (Jump if Less or Equal): Jumps if the first value is less than or equal to the second.

ASM Syntax: `JMP label` | `JE label` | `JNE label` | `JG label` | `JL label`

| **C Code**                  | **ASM Code**            |
|-------------                |----------------         |
| `if (a == b) {`             | `CMP eax, ebx`          |
|                             | `JNE else_label`        |
|     `// some code here`     | `; some code here`      |
|                             | `JMP end_if`            |
| `} else {`                  | `else_label:`           |
|     `some other code here`  | `; some other code here`|
| `}`                         | `end_if:`               |

### Loops

The `for` and `while` are included in the program (no `do while`) in a very specific form:
- There will be no nested `for`, `if` or `while` instructions
- None of the three components of the `for` instruction will be absent
- The coding style of the input will always be consistent with the given examples (whitespaces)
- Any relational operator is allowed (`==`, `!=`, `<`, `<=`, `>`, `>=`)
- Loops should not be infinite
- End loop label names will be placeholders

| **C Code**                    | **ASM Code**          |
|-------------                  |----------------       |
| `for (a = 0; a < 10; a++) {`  | `MOV eax, 0`          |
|                               | `start_loop:`         |
|                               | `CMP eax, 10`         |
|                               | `JGE end_loop`        |
| `// some code here`           | `; some code here`    |
|                               | `ADD eax, 1`          |
|                               | `JMP start_loop`      |
| `}`                           | `end_loop:`           |

| **C Code**          | **ASM Code**                                          |
|-------------        |----------------                                       |
| `while (b < 5) {`   | `start_loop:`                                         |
|                     | `CMP ebx, 5`                                          |
|                     | `JGE end_loop`                                        |
| `// some code here` | `; some code that makes b greater than or equal to 5` |
|                     | `JMP start_loop`                                      |
| `}`                 | `end_loop:`                                           |

## Running the Program

- For simplicity, the program expects one instruction at a time from stdin
- The most recently written line will be transpiled and immediately printed to stdout
- A Makefile is provided, with the `build`, `run` and `clean` rules
- From the terminal, enter `make run` and start providing the right instructions with an Enter
