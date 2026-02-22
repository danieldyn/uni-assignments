# Task 2 - Events

## Objective

The goal is to sort a vector of structures by several criteria. 
There are two structures used for this task, which are both packed:

```c
    struct date {
        uint8_t day;
        uint8_t month;
        uint16_t year;
    };

    struct event {
        char name[31];
        uint8_t valid;
        struct date date;
    };
```

### Subtask 1

Before sorting the events, the program runs a check if the date of each event is valid, based on the next rules:

- The year should be between 1990 and 2030
- The month should be between 1 and 12
- The day should be between 1 and the last day of each month (e.g. for January the last day is 31, for February, it is 28)

If a date is valid, the `valid` flag in the `event` structure is set to 1 (True), to 0 (False) otherwise.

The function definition is:

```c
void check_events(struct event *events, int len);
```

The arguments are:

- **events:** start address of the events array
- **len:** number of events in the array

### Subtask 2

This subtask does the actual sorting **in place**, following the next steps while comparing two events:

- if an event is valid, it is **not** considered greater, which means all the valid events should come **first**
- if two events are valid, they should be sorted by their year, then by month, then by day
- if the dates of two events are equal, they should be sorted like using `strcmp()` function by their name and using its result; if the result is negative, the first name should come first in the sorted array

The function definition is:

```c
void sort_events(struct event *events, int len);
```

The arguments are:

- **events:** start address of the events array
- **len:** number of events in the array

>**Note:** All the data in the structures will be limited to their data type size and the name of the events is unique.

## Running the Program
- A Makefile with the `build`, `run` and `clean` rules is provided
- Edit the `checker.c` file, declaring a vector of structures for testing (or use the default one)
- From the terminal, enter `make run` and inspect the output
