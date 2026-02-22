CC = gcc
FLAGS = -Wall
PROGS = packs
all: $(PROGS)

packs: packs.c
	$(CC) packs.c -lm -o packs $(FLAGS)

clean:
	rm -f *~ *.out $(PROGS)
