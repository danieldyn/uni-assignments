.PHONY: all clean run build

all: checker

build: checker

run: checker
	./checker

sort.o: sort.asm
	nasm -f elf $^ -o $@

checker.o: checker.c
	gcc -c -g -m32 -no-pie $^ -o $@

checker: sort.o checker.o
	gcc -m32 -g -no-pie $^ -o $@

clean:
	rm checker
	rm *.o
