#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

struct date {
    uint8_t day;
    uint8_t month;
    uint16_t year;
} __attribute__((packed));

struct event {
    char name[31];
    uint8_t valid;
    struct date date;
} __attribute__((packed));

extern void check_events(struct event *events, int len);
extern void sort_events(struct event *events, int len);

int main()
{
	// declare an array of events for testing
	// it should have: valid and invalid events, events with the same date but different name 
	struct event arr[5];

	arr[0].date.day = 21;
	arr[0].date.month = 4;
	arr[0].date.year = 1994;
	arr[0].valid = 0;
	strcpy(arr[0].name, "Vivaldi Concert");

	arr[1].date.day = 15;
	arr[1].date.month = 6;
	arr[1].date.year = 2005;
	arr[1].valid = 0;
	strcpy(arr[1].name, "Football Match");

	arr[2].date.day = 31;
	arr[2].date.month = 15;
	arr[2].date.year = 2025;
	arr[2].valid = 0;
	strcpy(arr[2].name, "Baroque Exhibition");

	arr[3].date.day = 21;
	arr[3].date.month = 4;
	arr[3].date.year = 1994;
	arr[3].valid = 0;
	strcpy(arr[3].name, "Film Launch");

	arr[4].date.day = 2;
	arr[4].date.month = 10;
	arr[4].date.year = 1880;
	arr[4].valid = 0;
	strcpy(arr[4].name, "Peace Conference");


	// other needed variables
	int i, n = sizeof(arr) / sizeof(struct event);

	// print the initial array
	printf("\nInitial array:\n");

	for (i = 0; i < n; i++)
		printf("Validity: %hhu   Date: %02hhu/%02hhu/%04hu   Name: %-30s\n",
			arr[i].valid,
			arr[i].date.day, arr[i].date.month, arr[i].date.year,
			arr[i].name);
	
	// call the functions
	check_events(arr, n);
	sort_events(arr, n);

	// print the new array
	printf("\nNew array:\n");

	for (i = 0; i < n; i++)
		printf("Validity: %hhu   Date: %02hhu/%02hhu/%04hu   Name: %-30s\n",
			arr[i].valid,
			arr[i].date.day, arr[i].date.month, arr[i].date.year,
			arr[i].name);

	return 0;
}
