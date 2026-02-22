#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct page {
	int id;
	char url[51];
	char *description;
} *webpage;

typedef struct stack {
	webpage stackPage;
	struct stack *next;
} stackCell, *pageStack;

typedef struct tab {
	int id;
	struct page *currentPage;
	struct stack *backwardStack;
	struct stack *forwardStack;
} *webtab;

typedef struct tabsList {
	webtab tab;
	struct tabsList *prev;
	struct tabsList *next;
} listNode, *tabList;

typedef struct browser {
	struct tab *current;
	struct tabsList list;
} *webbrowser;

// Function that checks whether the stack is empty
int isPageStackEmpty(pageStack s)
{
	return (s == NULL);
}

// Function that pushes an element onto the stack
pageStack push(pageStack s, webpage p)
{
	pageStack t;

	t = (pageStack)malloc(sizeof(stackCell));
	if (t == NULL) {
		printf("Error allocating memory.\n");
		exit(1);
	}

	t->stackPage = p;
	t->next = s;
	
	return t;
}

// Function that pops the element on top of the stack
pageStack pop(pageStack s)
{
	pageStack t;

	t = s;
	s = s->next;
	free(t);
	
	return s;
}

// Function that returns the element on top of the stack without popping it
webpage top(pageStack s)
{
	return s->stackPage;
}

// Function that adds a new cell in the list after pos
void addTab(tabList new, tabList pos)
{
	// connect new cell with its neighbours
	new->prev = pos;
	new->next = pos->next;
	
	// update neighbours' pointers
	pos->next = new;
	new->next->prev = new;
}

// Function that deletes a cell from the list and frees all memory
void delTab(tabList t)
{
	// update neighbours' pointers
	t->prev->next = t->next;
	t->next->prev = t->prev;
	
	// empty both stacks
	while (t->tab->backwardStack != NULL)
		t->tab->backwardStack = pop(t->tab->backwardStack);
	while (t->tab->forwardStack != NULL)
		t->tab->forwardStack = pop(t->tab->forwardStack);
	
	// free memory
	free(t->tab);
	free(t);
}

// Function that prints the error message in the output file
void printError(FILE *output)
{
	fprintf(output, "403 Forbidden\n");
}

// Function that adds the default page to the vector
void addDefaultPage(webpage *pages)
{
	int len;

	pages[0] = (webpage)malloc(sizeof(struct page));
	if (pages[0] == NULL) {
		printf("Error allocating memory.\n");
		exit(1);
	}
	
	// default ID
	pages[0]->id = 0;

	// default URL
	strcpy(pages[0]->url, "https://acs.pub.ro/");

	//default description
	len = strlen("Computer Science\n") + 1;
	pages[0]->description = (char *)malloc(len * sizeof(char));
	if (pages[0]->description == NULL) {
		printf("Error allocating memory.\n");
		exit(1);
	}
	strcpy(pages[0]->description, "Computer Science\n");
}

// Function that builds the vector of page pointers from the given input file
void readPageData(webpage *pages, int nrPages, FILE *input)
{
	int i, len;
	char line[256];

	for (i = 1; i <= nrPages; i++) {
		pages[i] = (webpage)malloc(sizeof(struct page));
		if (pages[i] == NULL) {
			printf("Error allocating memory.\n");
			exit(1);
		}

		// read ID and eliminate newline from buffer
		fscanf(input, "%d", &pages[i]->id);
		fgetc(input);

		// read URL and remove newline
		fgets(line, 51, input);
		line[strcspn(line, "\n")] = '\0';
		strcpy(pages[i]->url, line);

		// read description and keep newline
		fgets(line, 255, input);
		len = strlen(line) + 1;
		pages[i]->description = (char *)malloc(len * sizeof(char));
		if (pages[i]->description == NULL) {
			printf("Error allocating memory.\n");
			exit(1);
		}
		strcpy(pages[i]->description, line);
	}
}

// Function that performs the first task
void NEW_TAB(webbrowser brow, webpage defPage, int *lastTabID)
{
	webtab t;
	tabList new, last;

	t = (webtab)malloc(sizeof(struct tab));
	if (t == NULL) {
		printf("Error allocating memory.\n");
		exit(1);
	}

	new = (tabList)malloc(sizeof(listNode));
	if (new == NULL) {
		printf("Error allocating memory.\n");
		exit(1);
	}

	// fill in the fields of the new tab
	t->id = ++(*lastTabID);
	t->backwardStack = NULL;
	t->forwardStack = NULL;
	t->currentPage = defPage;

	// update pointers to the new tab
	new->tab = t;
	brow->current = t;

	// insert new tab at the end of the list
	last = brow->list.prev;
	addTab(new, last);
}

// Function that performs the second task
void CLOSE(webbrowser brow, FILE *output)
{
	tabList t;

	// avoid deleting the default page
	if (brow->current->id == 0) {
		printError(output);
		return;
	}

	// search for the current tab in the list
	t = brow->list.next;
	while (t->tab != brow->current)
		t = t->next;

	// set the previous tab to current
	brow->current = t->prev->tab;

	// remove the former current tab
	delTab(t);
}

// Function that performs the third task
void OPEN(webbrowser brow, int id, FILE *output)
{
	tabList t;

	// search for the tab with the given ID
	t = brow->list.next;
	while (t != &(brow->list) && t->tab->id != id)
		t = t->next;

	// if the sentinel was reached, the tab does not exist
	if (t == &(brow->list)) {
		printError(output);
		return;
	}

	// else, set found tab as current
	brow->current = t->tab;
}

// Function that performs the fourth task
void NEXT(webbrowser brow)
{
	tabList t;

	// search for the current tab in the list
	t = brow->list.next;
	while (t->tab != brow->current)
		t = t->next;

	// avoid setting the sentinel as the current tab
	if (t->next == &(brow->list))
		t = t->next;
	
	// set the next tab as current
	brow->current = t->next->tab;
}

// Function that performs the fifth task
void PREV(webbrowser brow)
{
	tabList t;

	// search for the curent tab in the list
	t = brow->list.next;
	while (t->tab != brow->current)
		t = t->prev;

	// avoid setting the sentinel as the current tab
	if (t->prev == &(brow->list))
		t = t->prev;

	// set the previous tab as current
	brow->current = t->prev->tab;
}

// Function that performs the sixth task
void PAGE(webtab crtTab, int ID, webpage *pages, int nrPages, FILE *output)
{
	int i, pos = -1;

	for (i = 0; i <= nrPages && pos == -1; i++)
		if (pages[i]->id == ID)
			pos = i;

	// check if the page was found
	if (pos == -1) {
		printError(output);
		return;
	}

	// push the current page on the backward stack
	crtTab->backwardStack = push(crtTab->backwardStack, crtTab->currentPage);

	// empty the forward stack
	while (!isPageStackEmpty(crtTab->forwardStack))
		crtTab->forwardStack = pop(crtTab->forwardStack);
	
	// set the new current page of the tab
	crtTab->currentPage = pages[pos];
}

// Function that performs the seventh task
void BACKWARD(webtab crtTab, FILE *output)
{
	webpage p;

	// check if the backward stack is already empty
	if (isPageStackEmpty(crtTab->backwardStack)) {
		printError(output);
		return;
	}

	// save the element on top of the backward stack and pop it
	p = top(crtTab->backwardStack);
	crtTab->backwardStack = pop(crtTab->backwardStack);

	// push the current page on the forward stack
	crtTab->forwardStack = push(crtTab->forwardStack, crtTab->currentPage);

	// set the new current page
	crtTab->currentPage = p;
}

// Function taht performs the eigth task
void FORWARD(webtab crtTab, FILE *output)
{
	webpage p;

	// check if the forward stack is already empty
	if (isPageStackEmpty(crtTab->forwardStack)) {
		printError(output);
		return;
	}

	// save the element on top of the forward stack and pop it
	p = top(crtTab->forwardStack);
	crtTab->forwardStack = pop(crtTab->forwardStack);
	
	// push the current page on the backward stack
	crtTab->backwardStack = push(crtTab->backwardStack, crtTab->currentPage);

	//se the new current page
	crtTab->currentPage = p;
}

// Function that performs the ninth task
void PRINT(webbrowser brow, FILE *output)
{
	tabList t;

	// search for the current tab in the list
	t = brow->list.next;
	while (t->tab != brow->current)
		t = t->next;
	
	// print the ID of the current tab 
	fprintf(output, "%d", t->tab->id);

	// print the other IDs circularly
	t = t->next;
	while (t->tab != brow->current) {
		// avoid printing the sentinel
		if (t == &(brow->list))
			t = t->next;
		else {
			fprintf(output, " %d", t->tab->id);
			t = t->next;
		}
	}

	// print the description of the current page
	fprintf(output, "\n%s", brow->current->currentPage->description);
}

// Function that prints the URLs of the pages on the forward stack down-top
void printForwardStackURL(pageStack s, FILE *output)
{
	// base case for recursion
	if (s == NULL)
		return;
	
	// call recursively to ensure correct printing order
	printForwardStackURL(s->next, output);
	
	// print the current URL
	fprintf(output, "%s\n", s->stackPage->url);
}

// Function that prints the URLs of the pages on the backward stack top-down
void printBackwardStackURL(pageStack s, FILE *output)
{
	pageStack p;
	
	// loop through the stack cells starting from the top
	p = s;
	while (p != NULL) {
		fprintf(output, "%s\n", p->stackPage->url);
		p = p->next;
	}
}

// Function that performs the tenth task
void PRINT_HISTORY(webbrowser brow, int ID, FILE *output)
{
	tabList t;

	// search for the tab with the given ID
	t = brow->list.next;
	while (t != &(brow->list) && t->tab->id != ID)
		t = t->next;

	// check if the tab does not exist
	if (t == &(brow->list)) {
		printError(output);
		return;
	}

	// print the forward stack URLs
	printForwardStackURL(t->tab->forwardStack, output);

	// print the current page URL
	fprintf(output, "%s\n", t->tab->currentPage->url);

	// print the backward stack URL
	printBackwardStackURL(t->tab->backwardStack, output);
}

// Function that frees all used memory
void freeMemory(webbrowser brow, webpage *pages, int nrPages)
{
	int i;
	tabList t, s;

	// free page pointer vector
	for (i = 0; i <= nrPages; i++) {
		free(pages[i]->description);
		free(pages[i]);
	}
	free(pages);


	// free tab list
	t = brow->list.next;
	while (t != &(brow->list)) {
		// save the address of the next node
		s = t->next;

		// empty the backward stack
		while (!isPageStackEmpty(t->tab->backwardStack))
			t->tab->backwardStack = pop(t->tab->backwardStack);

		// empty the forward stack
		while (!isPageStackEmpty(t->tab->forwardStack))
			t->tab->forwardStack = pop(t->tab->forwardStack);

		// free the tab
		free(t->tab);
		free(t);

		// move to the next node
		t = s;
	}

	// free the browser
	free(brow);
}

int main()
{
	// local variables
	FILE *input, *output;
	webpage *pages;
	webtab defTab;
	tabList defTabNode;
	webbrowser brow;
	int nrPages, nrOps, i, lastTabID = 0;
	char instr[21];

	// open the input file
	input = fopen("tema1.in", "r");
	if (input == NULL) {
		printf("Error opening input file.\n");
		exit(1);
	}
	
	// open the output file
	output = fopen("tema1.out", "w");
	if (output == NULL) {
		printf("Error opening output file.\n");
		exit(1);
	}

	// create the vector of page pointers
	fscanf(input, "%d", &nrPages);
	fgetc(input);
	
	pages = (webpage *)calloc(nrPages + 1, sizeof(webpage));
	if (pages == NULL) {
		printf("Error allocating memory.\n");
		exit(1);
	}

	addDefaultPage(pages);
	readPageData(pages, nrPages, input);
	
	// initialise the default tab
	defTab = (webtab)calloc(1, sizeof(struct tab));
	if (defTab == NULL) {
		printf("Error allocating memory.\n");
		exit(1);
	}

	defTab->id = 0;
	defTab->currentPage = pages[0];
	defTab->backwardStack = NULL;
	defTab->forwardStack = NULL;
	
	// initialise the browser
	brow = (webbrowser)calloc(1, sizeof(struct browser));
	if (brow == NULL) {
		printf("Error allocating memory.\n");
		exit(1);
	}

	brow->list.next = &(brow->list);
	brow->list.prev = &(brow->list);
	brow->current = defTab;
	
	// initialise the tab list
	defTabNode = (tabList)calloc(1, sizeof(listNode));
	if (defTabNode == NULL) {
		printf("Error allocating memory.\n");
		exit(1);
	}

	defTabNode->tab = defTab;
	addTab(defTabNode, &(brow->list));
	
	// read the requested tasks and complete them
	fscanf(input, "%d", &nrOps);
	fgetc(input);

	for (i = 0; i < nrOps; i++) {
		// read the current task and eliminate newline
		fgets(instr, 20, input);
		instr[strcspn(instr, "\n")] = '\0';

		// determine which task is to be solved
		if (strncmp(instr, "NEW_TAB", 7) == 0)
			NEW_TAB(brow, pages[0], &lastTabID);
		else if (strncmp(instr, "CLOSE", 5) == 0)
			CLOSE(brow, output);
		else if (strncmp(instr, "OPEN", 4) == 0) {
			char *id = strrchr(instr, ' ') + 1;
			OPEN(brow, atoi(id), output);
		} else if (strncmp(instr, "NEXT", 4) == 0)
			NEXT(brow);
		else if (strncmp(instr, "PREV", 4) == 0)
			PREV(brow);
		else if (strncmp(instr, "PAGE", 4) == 0) {
			char *id = strrchr(instr, ' ') + 1;
			PAGE(brow->current, atoi(id), pages, nrPages, output);
		} else if (strncmp(instr, "BACKWARD", 8) == 0)
			BACKWARD(brow->current, output);
		else if (strncmp(instr, "FORWARD", 7) == 0)
			FORWARD(brow->current, output);
		else if (strncmp(instr, "PRINT_HISTORY", 13) == 0) {
			char *id = strrchr(instr, ' ') + 1;
			PRINT_HISTORY(brow, atoi(id), output);
		}
		else if (strncmp(instr, "PRINT", 5) == 0)
			PRINT(brow, output);
		else
			fprintf(output, "Task <%s> not recognised.\n", instr);
	}

	// close files
	fclose(input);
	fclose(output);

	// free memory
	freeMemory(brow, pages, nrPages);
	
	return 0;
}
