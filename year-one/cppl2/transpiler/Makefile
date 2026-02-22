CC = gcc
CFLAGS = -Wall -Wextra -Werror -g -std=c11
TARGET = transpiler

.PHONY: all build run clean

all: build

build:
	$(CC) $(CFLAGS) -o $(TARGET) main.c

run: build
	./$(TARGET)

clean:
	rm $(TARGET)
