.PHONY: all clean run build

all: checker

build: checker

run: checker
	./checker

operations.o: operations.asm
	nasm -f elf $^ -o $@

checker.o: checker.c
	gcc -c -g -m32 -no-pie $^ -o $@

checker: operations.o checker.o
	gcc -m32 -g -no-pie $^ -o $@

clean:
	rm checker
	rm *.o
