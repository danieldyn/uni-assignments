#include <stdio.h>
#include <stdlib.h>

typedef struct node {
	int val;
	struct node* next;
} Node;

extern struct node* sort(int n, struct node* node);

int main()
{
	// declare a list for testing and the number of nodes (n)
	// it should have: numbers between 1 the chosen n
	int n = 3;
	Node list[3];

	list[0].val = 2;
	list[0].next = NULL;

	list[1].val = 1;
	list[1].next = NULL;

	list[2].val = 3;
	list[2].next = NULL;

	// other needed variables
	int i;
	Node *p, *head;

	// print the initial list
	printf("\nInitial List: ");
	for (i = 0; i < n - 1; i++)
		printf("%d ", list[i].val);
	printf("%d\n", list[i].val);

	// call the function
	head = sort(n, list);

	// print the final list
	printf("Final List: ");
	for (p = head; p->next != NULL; p = p->next)
		printf("%d ", p->val);
	printf("%d\n", p->val);

	return 0;
}
