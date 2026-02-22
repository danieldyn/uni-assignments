.PHONY: all clean run build

all: checker

build: checker

run: checker
	./checker

composite_palindrome.o: composite_palindrome.asm
	nasm -f elf $^ -o $@

checker.o: checker.c
	gcc -c -g -m32 -no-pie $^ -o $@

checker: composite_palindrome.o checker.o
	gcc -m32 -g -no-pie $^ -o $@

clean:
	rm checker
	rm *.o
