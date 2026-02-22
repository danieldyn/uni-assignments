.PHONY: all clean run build

all: checker

build: checker

run: checker
	./checker

subtask1.o: subtask1.asm
	nasm -f elf $^ -o $@

subtask2.o: subtask2.asm
	nasm -f elf $^ -o $@

checker.o: checker.c
	gcc -c -g -m32 $^ -o $@

checker: checker.o subtask1.o subtask2.o
	gcc -no-pie -m32 -g $^ -o $@

clean:
	rm checker
	rm *.o
