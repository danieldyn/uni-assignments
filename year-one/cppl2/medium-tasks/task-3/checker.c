#include <stdio.h>

extern int kfib(int n, int K);

int main()
{
	// declare a value for n and K
	// be careful about the amount of recursive calls that will be performed
	int n = 11, K = 3;

	// other needed variables
	int result;

	// print the parameters
	printf("\nChosen parameters: n = %d and K = %d\n", n, K);

	// call the function
	result = kfib(n, K);

	// print the result
	printf("In the %dFib sequence, term number %d is: %d\n", K, n, result);

	return 0;
}
