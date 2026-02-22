CC = gcc
CFLAGS = -Wall -Werror -g
TARGET = tema1
SRC = tema1.c

.PHONY: all build clean run

all: build

build:
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC)

run: build
	./$(TARGET)

clean:
	rm $(TARGET)
