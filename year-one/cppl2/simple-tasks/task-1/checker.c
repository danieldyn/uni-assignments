#include <stdio.h>
#include <stdlib.h>

extern void remove_numbers(int *, int, int *, int *);

int main()
{
	// declare an array for testing
	// it should have: 0 (edge case), powers of 2, odd and even numbers 
	int arr[] = {1, 7, 2, 63, 44, 0, 4, 77, 80, 54, 13};

	// other needed variables
	int i, n = sizeof(arr) / sizeof(int);
	int len, *new_arr = (int *)malloc(n * sizeof(int));

	// print the initial array
	printf("\nInitial array: ");

	for (i = 0; i < n - 1; i++)
		printf("%d ", arr[i]);
	
	printf("%d\n", arr[i]);

	// call the function
	remove_numbers(arr, n, new_arr, &len);

	// print the new array
	printf("New array: ");

	for (i = 0; i < len - 1; i++)
		printf("%d ", new_arr[i]);
	
	printf("%d\n", new_arr[i]);

	// free memory
	free(new_arr);

	return 0;
}