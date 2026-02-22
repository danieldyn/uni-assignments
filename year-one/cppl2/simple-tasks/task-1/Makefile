.PHONY: all clean run build

all: checker

build: checker

run: checker
	./checker

remove_numbers.o: remove_numbers.asm
	nasm -f elf $^ -o $@

checker.o: checker.c
	gcc -c -g -m32 -no-pie $^ -o $@

checker: checker.o  remove_numbers.o
	gcc -m32 -g -no-pie $^ -o $@

clean:
	rm checker
	rm *.o
