# Computer Programming and Programming Languages 1
# C Mail Delivery Program

This program processes and simulates mail delivery operations across multiple districts of a fictional city. It supports data input and task execution ranging from basic parsing to scoring mailmen based on delivery success.

## Input Format

1. `request` - The number of the task that will be solved (`1`–`7`)  
2. `nrDistricts` - The number of districts/mailmen  
3. `nrDistricts` lines containing the names of each district  
   - No whitespaces in names  
   - Each district name ends with a newline  
4. `nrPackages` - The number of packages  
5. For **each package**, provide 4 lines:
   - 18 integers (`0` or `1`, separated by a single whitespace)
   - Priority (`1`–`5`)
   - Weight (maximum 3 decimals)
   - Message on the package

## Possible Tasks

### Task 1 – Check Input Reading
- Print all district names
- Print each package’s full input

### Task 2 – Extract Address
- Determine the address of each package
- Complete the corresponding field
- Print the updated package information

### Task 3 – Distribute Packages
- Assign packages to the corresponding mailmen
- Print each mailman's packages to verify distribution

### Task 4 – Sort Packages
- Sort each mailman’s list of packages
- Print the sorted lists

### Task 5 – Encode Message and Generate Code
- Encode the message of each package
- Calculate the package's code
- Print encoded messages and codes

### Task 6 – Alter Package Code (Conditional)
For every package whose ID shares **at least one digit** with the **ID of its postman**:

1. Find the **prime divisors** between 2 and 31 of the postman ID  
   - If the ID is 0 or 1, that value is the only divisor
2. In the **binary representation** of the package code:  
   - **Flip bits** at positions given by the prime divisors  
   - Bit positions are considered from **LSB → MSB**

### Task 7 – Score Mailmen
- A **mailman's score** is: score = (number of successfully delivered packages) / (total packages)
- A package is **successfully delivered** only if its code was **not altered** by the Task 6 algorithm

## Notes
- A simple Makefile is provided, containing the build, run and clean rules
