#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int check_row(char *sudoku, int row);
extern int check_column(char *sudoku, int column);
extern int check_box(char *sudoku, int box);

int main()
{
	// declare a string of excatly 81 numbers for testing
	// it should have: numbers between 1 and 9 (some zeroes if you want invalid portions)
	char sudoku[] = "504678912672195348198342567859761423426853791713924856961537284087419635345286179";

	// other needed variables
	int i, j;

	// print the board
	printf("\nSudoku Board:\n+-------+-------+-------+\n");
	
	for (i = 0; i < 9; i++) {
    	printf("| ");
    	for (j = 0; j < 9; j++) {
        	printf("%c ", sudoku[9 * i + j]);

			// check for end of box
        	if ((j + 1) % 3 == 0)
            	printf("| ");
    	}
    	
		printf("\n");
    
		if ((i + 1) % 3 == 0)
        	printf("+-------+-------+-------+\n");
	}

	// perform row checks
	printf("\nRow Checks: ");

	for (i = 0; i < 8; i++)
		printf("%d ", check_row(sudoku, i));
	printf("%d\n", check_row(sudoku, i));

	// perform column checks
	printf("\nColumn Checks: ");

	for (i = 0; i < 8; i++)
		printf("%d ", check_column(sudoku, i));
	printf("%d\n", check_column(sudoku, i));

	// perform box checks
	printf("\nBox Checks: ");

	for (i = 0; i < 8; i++)
		printf("%d ", check_box(sudoku, i));
	printf("%d\n", check_box(sudoku, i));
	
	return 0;
}
