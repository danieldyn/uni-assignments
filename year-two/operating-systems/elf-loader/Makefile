CC = gcc
CFLAGS = -Wall -Wextra -g
LDFLAGS = -static-pie

LOADER = elf-loader
LOADER_SRC = elf-loader.c

TEST_C_STATIC = hello_static
TEST_C_PIE = hello_static_pie
TEST_C_SRC = hello.c

.PHONY: all clean test_payloads

all: $(LOADER) test_payloads

$(LOADER): $(LOADER_SRC)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

test_payloads: $(TEST_C_STATIC) $(TEST_C_PIE)

$(TEST_C_STATIC): $(TEST_C_SRC)
	$(CC) $(CFLAGS) -static -o $@ $<

$(TEST_C_PIE): $(TEST_C_SRC)
	$(CC) $(CFLAGS) -static-pie -o $@ $<

clean:
	rm -f $(LOADER) $(TEST_C_STATIC) $(TEST_C_PIE) *.o
