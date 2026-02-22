#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern void get_words(char *s, char **words, int number_of_words);
extern void sort(char **words, int number_of_words, int size);

int main()
{
	// declare a string for testing and the number of words
	// it should have: characters, separators ' ,.\n'
	int n = 16;
	char text[] = "Your mission, should you choose to accept it, is to sort the words in this text.";

	// other needed variables
	int i;
	char **words = (char **)calloc(n, sizeof(char *));

	// print the initial text
	printf("\nText: %s\n", text);

	// call the functions
	get_words(text, words, n);
	sort(words, n, sizeof(char *));

	// print the words
	printf("Words:");
	for (i = 0; i < n - 1; i++)
		printf(" %s |", words[i]);
	printf(" %s\n", words[i]);

	// free memory
	free(words);

	return 0;
}
