CC = gcc
CFLAGS = -Wall -Werror -g
TARGET = tema2
SRC = tema2.c
ARGS = tema2.in tema2.out

.PHONY: all build clean run1 run2 run3 run4 run5

all: build

build:
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC)

run1: build
	./$(TARGET) -c1 $(ARGS)

run2: build
	./$(TARGET) -c2 $(ARGS)

run3: build
	./$(TARGET) -c3 $(ARGS)

run4: build
	./$(TARGET) -c4 $(ARGS)

run5: build
	./$(TARGET) -c5 $(ARGS)

clean:
	rm $(TARGET)