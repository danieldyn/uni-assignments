.PHONY: all clean run build

all: checker

build: checker

run: checker
	./checker

base64.o: base64.asm
	nasm -f elf $^ -o $@

checker.o: checker.c
	gcc -c -g -m32 $^ -o $@

checker: checker.o  base64.o
	gcc -m32 -no-pie -g $^ -o $@

clean:
	rm checker
	rm *.o
