#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern char* composite_palindrome(const char **strs, const int len);

int main()
{
	// declare an array of words for testing and the number of words
	// it should have: letters a-z, A-Z
	int n = 5;
	const char *strs[] = {"no", "abba", "oiu", "on", "cnnc"};

	// other needed variables
	int i;
	char *result;

	// print the array of words
	printf("\nStrings:");
	for (i = 0; i < n - 1; i++)
		printf(" %s |", strs[i]);
	printf(" %s\n", strs[i]);

	// call the function
	result = composite_palindrome(strs, n);

	// print the result
	printf("Composite palindrome: %s\n", result);

	// free memory
	free(result);

	return 0;
}
