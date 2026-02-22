#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct multiNode {
	int freq;
	char name[16];
	int nrChildren;
	struct multiNode *parent;
	struct multiNode **children;
} *multiTree;

typedef struct satellite {
	int freq;
	char *name;
	struct satellite *right;
	struct satellite *left;
	struct satellite *parent;
	multiTree multiRoot;
} *SatTree;

typedef struct heap {
	int size;
	SatTree *satellites;
} *Heap;

typedef struct cell {
	SatTree elem;
	struct cell *next;
} *PQueue;

typedef struct queue {
	PQueue front;
	PQueue rear;
} SatQueue;

// Function that adds a satellite to the queue
SatQueue enqueue(SatQueue q, SatTree s)
{
	PQueue new;
	
	new = (PQueue)malloc(sizeof(struct cell));
	if (new == NULL) {
		printf("Error allocating memory\n");
		return q;
	}

	new->elem = s;
	new->next = NULL;
	
	if (q.front == NULL) {
		q.front = new;
		q.rear = new;
	}
	else {
		q.rear->next = new;
		q.rear = new;
	}

	return q;
}

// Function that removes a satellite from the queue
SatQueue dequeue(SatQueue q)
{
	PQueue p;

	if (q.front == q.rear) {
		free(q.front);
		q.front = NULL;
		q.rear = NULL;
	}
	else {
		p = q.front;
		q.front = q.front->next;
		free(p);
	}

	return q;
}

// Function that allocates memory for a new satellite and initialises it
SatTree buildNode(char *name, int freq, SatTree left, SatTree right)
{
	int len;
	SatTree new;
	
	len = strlen(name) + 1;
	new = (SatTree)malloc(sizeof(struct satellite));
	if (new == NULL) {
		printf("Error allocating memory\n");
		return NULL;
	}
	
	new->name = (char *)malloc(len * sizeof(char));
	if (new->name == NULL) {
		printf("Error allocating memory\n");
		return NULL;
	}

	// complete the fundamental fields of the satellite
	strcpy(new->name, name);
	new->freq = freq;
	new->left = left;
	new->right = right;

	// initialise the fields related to the multi root component
	new->multiRoot = NULL;
	new->parent = NULL;
	if (left != NULL)
		left->parent = new;
	if (right != NULL)
		right->parent = new;
	
	return new;
}

// Function that compares two satellites
int compareSat(SatTree a, SatTree b)
{
	if (a->freq != b->freq)
		return a->freq - b->freq;
	
	return strcmp(a->name, b->name);
}

// Function that swaps two satellites
void swap(SatTree *a, SatTree *b)
{
	SatTree aux = *a;
	*a = *b;
	*b = aux;
}

// Min Heap sift up function 
void siftUp(Heap h, int i)
{
	// indexing starts from 1
	int parent = i / 2;

	while (i > 1 && compareSat(h->satellites[i], h->satellites[parent]) < 0) {
		swap(&h->satellites[i], &h->satellites[parent]);
		i = parent;
		parent /= 2;
	}
}

// Function that inserts a satellite in the Min Heap
void insert(Heap h, SatTree new)
{
	h->size++;
	h->satellites[h->size] = new;
	siftUp(h, h->size);
}

// Recursive Min Heap sift down function
void siftDown(Heap h, int i)
{
	int minIndex, left, right;
	
	if (2 * i > h->size)
		return;

	// indexing starts from 1
	minIndex = i;
	left = 2 * i;
	right = 2 * i + 1;

	if (left <= h->size && compareSat(h->satellites[minIndex], h->satellites[left]) > 0)
		minIndex = left;

	if (right <= h->size && compareSat(h->satellites[minIndex], h->satellites[right]) > 0)
		minIndex = right;
	
	if (i != minIndex) {
		swap(&h->satellites[i], &h->satellites[minIndex]);
		siftDown(h, minIndex);
	}

}

// Function that logically removes and returns the minimum element from the Min Heap
SatTree extractMin(Heap h)
{
	SatTree res;
	
	res = h->satellites[1];
	h->satellites[1] = h->satellites[h->size];
	h->size--;
	siftDown(h, 1);

	return res;
}

// Function that creates the binary tree from the initial Min Heap
SatTree buildTree(Heap h)
{
	SatTree left, right, parent;
	char *name;
	int freq, len;

	// check if a connection satellite can still be created
	while (h->size > 1) {
		// extract the two minimum elements
		left = extractMin(h);
		right = extractMin(h);

		// prepare the fields of the connection satellite
		len = strlen(left->name) + strlen(right->name) + 1;
		name = (char *)malloc(len * sizeof(char));
		strcpy(name, left->name);
		strcat(name, right->name);
		freq = left->freq + right->freq;

		// build the connection satellite and insert it in the Min Heap
		parent = buildNode(name, freq, left, right);
		insert(h, parent);

		// free memory before next iteration
		free(name);
	}

	// the remaining satellite is the root of the binary tree
	return h->satellites[1];
}

// Function that creates the initial Min Heap from the input data
void readSatellites(Heap h, int n, FILE *input)
{
	int i, freq;
	char name[16];
	SatTree new;

	for (i = 0; i < n; i++) {
		// read the input line with fixed format
		fscanf(input, "%d %s\n", &freq, name);

		// create the node and insert it in the right position
		new = buildNode(name, freq, NULL, NULL);
		insert(h, new);
	}
}

// Function that performs the first task
void bfsPrint(SatTree root, FILE *output)
{
	SatTree s;
	SatQueue q;
	PQueue p;
	int satNumber, i;

	// initialise the queue with the first level
	q.front = q.rear = NULL;
	q = enqueue(q, root);

	// loop through the levels
	while (q.front != NULL) {
		satNumber = 0;
		p = q.front;

		// count the number of satellites on the current level
		while (p != NULL) {
			satNumber++;
			p = p->next;
		}

		for (i = 0; i < satNumber; i++) {
			// print the current satellite
			s = q.front->elem;
			fprintf(output, "%d-%s ", s->freq, s->name);

			// enqueue the children of the printed satellite
			if (s->left != NULL)
				q = enqueue(q, s->left);
			
			if (s->right != NULL)
				q = enqueue(q, s->right);
			
			// remove the printed satellite from the queue
			q = dequeue(q);
		}

		// move to the next line
		fprintf(output, "\n");
	}
}

// Function that performs the second task
void decode(SatTree root, char *code, FILE *output)
{
	int i;
	SatTree s = root;

	for (i = 0; i < strlen(code); i++) {
		// choose which child to move to
		if (code[i] == '0')
			s = s->left;

		else if (code[i] == '1')
			s = s->right;
		
		// check if a leaf was encountered
		if (s->left == NULL && s->right == NULL) {
			// print the found satellite
			fprintf(output, "%s ", s->name);

			// restart from root
			s = root;
		}
	}

	// preserve good output format
	fprintf(output, "\n");
}

// Function that performs the third task
int encode(SatTree root, char *name, char *code)
{
	int res;

	// necessary base case for recursion
	if (root == NULL)
		return 0;

	// check if the current satellite is the sought one 
	if (strcmp(root->name, name) == 0) {
		*code = '\0';
		return 1;
	}
	
	// search the left subtree
	if (root->left != NULL) {
		*code = '0';
		res = encode(root->left, name, code + 1);

		// check if the subtree led to the answer
		if (res == 1)
			return 1;
	}

	// search the right subtree
	if (root->right != NULL) {
		*code = '1';
		res = encode(root->right, name, code + 1);

		// check if the subtree led to the answer
		if (res == 1)
			return 1;
	}

	return 0;
}

// Function that checks if the name of a satellite contains all given substrings
int searchAllNames(SatTree s, char *names[16], int n)
{
	int i;

	for (i = 0; i < n; i++)
		if (strstr(s->name, names[i]) == NULL)
			return 0;
	
	return 1;
}

// Function that performs the fourth task
char* findCommonParent(SatTree root, char *names[16], int n)
{
	char *res;

	// necessary base case for recursion
	if (root == NULL)
		return NULL;
	
	// check the left subtree
	res = findCommonParent(root->left, names, n);
	if (res != NULL)
		return res;

	// check the right subtree
	res = findCommonParent(root->right, names, n);
	if (res != NULL)
		return res;

	// check if the current satellite is the sought one
	if (searchAllNames(root, names, n) == 1)
		return root->name;
	
	return NULL;
}

// Function that searches a satellite in the binary tree by name
SatTree dfsFind(SatTree root, char *name)
{
	SatTree res;

	// necessary base case for recursion
	if (root == NULL)
		return NULL;
	
	// search in the left subtree
	res = dfsFind(root->left, name);
	if (res != NULL)
		return res;
	
	// search in the right subtree
	res = dfsFind(root->right, name);
	if (res != NULL)
		return res;
	
	// check if the current satellite is the sought one
	if (strcmp(name, root->name) == 0)
		return root;
	
	return NULL;
}

// Function that searches a satellite in a multi tree by name
multiTree findMulti(multiTree root, char *name)
{
	int i;
	multiTree res;

	// necessary base case for recursion
	if (root == NULL)
		return NULL;
	
	// check if the current satellite is the sought one
	if (strcmp(root->name, name) == 0)
		return root;
	
	// check the children of the current satellite
	for (i = 0; i < root->nrChildren; i++) {
		res = findMulti(root->children[i], name);
		if (res != NULL)
			return res;
	}

	return NULL;
}

// Function that searches a satellite in all multi trees by name
multiTree find(SatTree root, char *name)
{
	multiTree res;

	// necessary base case for recursion
	if (root == NULL)
		return NULL;
	
	// search the left subtree
	res = find(root->left, name);
	if (res != NULL)
		return res;

	// search the right subtree
	res = find(root->right, name);
	if (res != NULL)
		return res;
	
	// search in the multi tree connected to the current satellite
	res = findMulti(root->multiRoot, name);
	if (res != NULL)
		return res;
	
	return NULL;
}

// Function that searches for the binary tree satellite connected to a multi tree root
SatTree findLink(SatTree root, multiTree m)
{
	SatTree res;

	// necessary base case for recursion
	if (root == NULL)
		return NULL;
	
	// search the left subtree
	res = findLink(root->left, m);
	if (res != NULL)
		return res;
	
	// search the right subtree
	res = findLink(root->right, m);
	if (res != NULL)
		return res;
	
	// check if the current satellite is the sought one
	if (root->multiRoot != NULL && root->multiRoot == m)
		return root;
	
	return NULL;
}

// Function that returns the depth of a satellite in the binary tree
int depthMain(SatTree root, SatTree s)
{
	int depth;

	for (depth = 0; s != root; depth++)  
			s = s->parent;
	
	return depth;
}

// Function that computes the distance between two satellites in the binary tree
// The function requires the depths of the two satellites to be passed as arguments
int distanceMain(SatTree s1, SatTree s2, int d1, int d2)
{
	int dist = 0;

	// bring the satellites at the same depth
	while (d1 < d2) {
		dist++;
		d2--;
		s2 = s2->parent;
	}

	while (d1 > d2) {
		dist++;
		d1--;
		s1 = s1->parent;
	}

	// bring the satellites in parallel to the first common ancestor
	while (s1 != s2) {
		dist += 2;
		s1 = s1->parent;
		s2 = s2->parent;
	}

	return dist;
}

// Function that performs the fifth task
int calculateDistance(SatTree root, char *name1, char *name2)
{
	int d1, d2, dist = 0;
	SatTree s1, s2;
	multiTree m1, m2;

	// begin the search in the binary tree
	s1 = dfsFind(root, name1);
	s2 = dfsFind(root, name2);

	// also search in all multi trees 
	m1 = find(root, name1);
	m2 = find(root, name2);

	// check if both satellites were found in the binary tree
	if (s1 != NULL && s2 != NULL) {
		d1 = depthMain(root, s1);
		d2 = depthMain(root, s2);
		return distanceMain(s1, s2, d1, d2);
	}

	//check if both satellites are in multi trees
	else if (m1 != NULL && m2 != NULL) {
		// search the root of the multi tree that they belong to
		while (m1->parent != NULL) {
			dist++;
			m1 = m1->parent;
		}

		while (m2->parent != NULL) {
			dist++;
			m2 = m2->parent;
		}

		// check if the satellites belong to the same multi tree
		if (m1 == m2)
			return dist;

		// otherwise, find the bridges to the bianry tree
		s1 = findLink(root, m1);
		s2 = findLink(root, m2);

		// "jump" to the binary tree, logically speaking
		dist += 2;

		// now the problem is reduced to the first case
		d1 = depthMain(root, s1);
		d2 = depthMain(root, s2);
		return dist + distanceMain(s1, s2, d1, d2);
	}

	// the remaining situations combine halves of the previous cases
	else if (s1 != NULL && m2 != NULL) {
		// second in multi tree, first in binary tree
		while (m2->parent != NULL) {
			dist++;
			m2 = m2->parent;
		}

		// bridge to the binary tree
		s2 = findLink(root, m2);
		dist++;
		
		// reduced to the first case
		d1 = depthMain(root, s1);
		d2 = depthMain(root, s2);
		return dist + distanceMain(s1, s2, d1, d2);
	}

	else if (m1 != NULL && s2 != NULL) {
		// first in multi tree, second in binary tree
		while (m1->parent != NULL) {
			dist++;
			m1 = m1->parent;
		}

		// bridge to the binary tree
		s1 = findLink(root, m1);
		dist++;

		// reduced to the first case
		d1 = depthMain(root, s1);
		d2 = depthMain(root, s2);
		return dist + distanceMain(s1, s2, d1, d2);
	}

	else
		return -1;   // at least one satellite does not exist
}

// Function that attaches the multi trees to the binary tree nodes
void readMultiTrees(SatTree tree, FILE *input)
{
	int nrTrees, nrParents, nrChildren, i, j, k, count, cap;
	char name[16];
	SatTree s;
	multiTree root, parent, child, *parents;
	
	fscanf(input, "%d\n", &nrTrees);
	for (i = 0; i < nrTrees; i++) {
		// start with the root of the current multi tree
		root = (multiTree)malloc(sizeof(struct multiNode));
		if (root == NULL) {
			printf("Error allocating memory\n");
			return;
		}

		// connect the root to the binary tree
		fscanf(input, "%s\n", name);
		s = dfsFind(tree, name);
		s->multiRoot = root;		

		// initialise the other fields of the root
		root->nrChildren = 0;
		root->children = NULL;
		root->parent = NULL;
		fscanf(input, "%d %s\n", &root->freq, root->name);

		// dynamically allocate a vector of parents
		fscanf(input, "%d\n", &nrParents);
		cap = nrParents * 2;
		parents = (multiTree *)malloc(cap * sizeof(multiTree));
		if (parents == NULL) {
			printf("Error allocating memory\n");
			return;
		}

		// so far, the only known parent is the root
		count = 0;
		parents[count++] = root;

		// manage the rest of the parents
		for (j = 0; j < nrParents; j++) {
			// search the parent in the vector by name
			fscanf(input, "%s\n", name);
			for (k = 0; k < count; k++)
				if (strcmp(parents[k]->name, name) == 0) {
					parent = parents[k];
					break;
				}
			
			// initialise the parent's vector of children
			fscanf(input, "%d\n", &nrChildren);
			parent->nrChildren = nrChildren;
			parent->children = (multiTree *)malloc(nrChildren * sizeof(multiTree));
			if (parent->children == NULL) {
				printf("Error allocating memory\n");
				return;
			}

			// manage the parent's children
			for (k = 0; k < nrChildren; k++) {
				child = (multiTree)malloc(sizeof(struct multiNode));
				if (child == NULL) {
					printf("Error allocating memory\n");
					return;
				}

				// initalise the child's fields
				child->nrChildren = 0;
				child->children = NULL;
				child->parent = parent;
				fscanf(input, "%d %s\n", &child->freq, child->name);

				// connect the parent to the child and assume the child may have children
				parent->children[k] = child;
				parents[count++] = child;

				// check if the parent vector's capacity was reached
				if (count >= cap) {
					parents = (multiTree *)realloc(parents, 2 * cap * sizeof(multiTree));
					if (parents == NULL) {
						printf("Error allocating memory\n");
						return;
					}
					cap *= 2;
				}
			}
		}
		free(parents);   // free before the next iteration
	}
}

// Function that frees all allocated memory for one multi tree
void freeMultiTree(multiTree root)
{
	int i;

	// necessary base case for recursion
	if (root == NULL)
		return;
	
	// recursively free each subtree
	for (i = 0; i < root->nrChildren; i++)
		freeMultiTree(root->children[i]);
	
	// free the current node
	free(root->children);
	free(root);
}

// Function that frees all allocated memory for all multi trees
void freeTreeMultiTrees(SatTree root)
{
	// necessary base case for recursion
	if (root == NULL)
		return;

	// free the multi trees in the left subtree
	freeTreeMultiTrees(root->left);

	// free the multi trees in the right subtree
	freeTreeMultiTrees(root->right);

	// free the multi root connection to the current node
	if (root->multiRoot != NULL) {
		freeMultiTree(root->multiRoot);
		root->multiRoot = NULL;
	}
}

// Function that frees all allocated memory for the binary tree
void freeTree(SatTree root)
{
	// necessary base case for recursion
	if (root == NULL)
		return;

	// free the left subtree
	freeTree(root->left);

	// free the right subtree
	freeTree(root->right);

	// free the current node
	free(root->name);
	free(root);
}

int main(int argc, char **argv)
{
	// local variables
	FILE *input, *output;
	int n, i, N;
	Heap h;
	SatTree root;
	char code[1001], name[256], **names, name1[16], name2[16];

	// command line argument check
	if (argc < 4) {
		printf("Insufficient command line arguments.\n");
		return 1;
	}

	// open the files provided as arguments
	input = fopen(argv[2], "r");
	output = fopen(argv[3], "w");
	if (input == NULL || output == NULL) {
		printf("Error opening files.\n");
		return 1;
	}

	// build the initial heap, necessary for all tasks
	fscanf(input, "%d\n", &n);
	h = (Heap)malloc(sizeof(struct heap));
	if (h == NULL) {
		printf("Error allocating memory\n");
		return 1;
	}

	// initialise heap fields
	h->size = 0;
	h->satellites = (SatTree *)malloc((n + 1) * sizeof(SatTree));
	if (h->satellites == NULL) {
		printf("Error allocating memory\n");
		return 1;
	}

	// call helper functions to build the heap
	readSatellites(h, n, input);
	root = buildTree(h);

	// solve the requested task
	if (strcmp(argv[1], "-c1") == 0) {
		bfsPrint(root, output);
	}

	else if (strcmp(argv[1], "-c2") == 0) {
		fscanf(input, "%d\n", &N);
		for (i = 0; i < N; i++) {
			fscanf(input, "%s\n", code);
			decode(root, code, output);
		}
	}

	else if (strcmp(argv[1], "-c3") == 0) {
		fscanf(input, "%d\n", &N);
		for (i = 0; i < N; i++) {
			fscanf(input, "%s\n", name);
			encode(root, name, code);
			fprintf(output, "%s", code);
		}
		fprintf(output, "\n");
	}

	else if (strcmp(argv[1], "-c4") == 0) {
		fscanf(input, "%d\n", &N);
		
		// create the vector of names
		names = (char **)malloc(N * sizeof(char *));
		if (names == NULL) {
			printf("Error allocating memory\n");
			return 1;
		}

		// max 16 characters per name in the initial network
		for (i = 0; i < N; i++) {
			names[i] = (char *)malloc(17 * sizeof(char));
			if (names[i] == NULL) {
				printf("Error allocating memory\n");
				return 1;
			}
			fscanf(input, "%s\n", names[i]);
		}

		// solve the task
		fprintf(output, "%s\n", findCommonParent(root, names, N));
		
		// free auxiliary memory
		for (i = 0; i < N; i++)
			free(names[i]);
		
		free(names);
	}

	else if (strcmp(argv[1], "-c5") == 0) {
		// read and attach all multi trees
		readMultiTrees(root, input);

		// solve the task
		fscanf(input, "%s %s", name1, name2);
		fprintf(output, "%d\n", calculateDistance(root, name1, name2));
		
		// free memory allocated for the multi tree section
		freeTreeMultiTrees(root);
	}

	// free memory allocated for any task
	free(h->satellites);
	free(h);
	freeTree(root);

	// close files
	fclose(input);
	fclose(output);

	return 0;
}