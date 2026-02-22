#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern void base64(char *a, int n, char *target, int *ptr_len);

int main()
{
	// declare a string for testing (length must be a multiple of 3)
	// it should have: small or capital letters from the English alphabet 
	char text[] = "YouShallNotPass";

	// other needed variables
	int n = strlen(text);
	int len = 2 * n;
	char *encoded = (char *)malloc(len * sizeof(char));

	// print the initial string
	printf("\nInitial string: %s\n", text);

	// call the function
	base64(text, n, encoded, &len);

	// print the new string
	printf("New string: %s\n", encoded);

	// free memory
	free(encoded);

	return 0;
}
