.PHONY: all clean run build

all: checker

build: checker

run: checker
	./checker

kfib.o: kfib.asm
	nasm -f elf $^ -o $@

checker.o: checker.c
	gcc -c -g -m32 -no-pie $^ -o $@

checker: kfib.o checker.o
	gcc -m32 -g -no-pie $^ -o $@

clean:
	rm checker
	rm *.o
