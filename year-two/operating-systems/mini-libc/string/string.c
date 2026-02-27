// SPDX-License-Identifier: BSD-3-Clause

#include <string.h>

char *strcpy(char *destination, const char *source)
{
    char *p;

    for (p = destination; *source != '\0'; p++) {
        *p = *source;
        source++;
    }

    *p = '\0'; // String terminator

    return destination;
}

char *strncpy(char *destination, const char *source, size_t len)
{
    char *p;
    size_t i = 0;

    for (p = destination; *source != '\0' && i < len; p++) {
        *p = *source;
        source++;
        i++;
    }

    // Padding
    while (i < len) {
        *p = '\0';
        i++;
    }

    return destination;
}

char *strcat(char *destination, const char *source)
{
    char *p;

    for (p = destination; *p != '\0'; p++)
        ;

    while (*source != '\0') {
        *p = *source;
		source++;
        p++;
    }

    *p = '\0'; // String terminator

    return destination;
}

char *strncat(char *destination, const char *source, size_t len)
{
    char *p;
    size_t i = 0;

    for (p = destination; *p != '\0'; p++)
        ;

    while (*source != '\0' && i < len) {
        *p = *source;
		source++;
        p++;
        i++;
    }

    *p = '\0'; // String terminator

    return destination;
}

int strcmp(const char *str1, const char *str2)
{
    while (*str1 != '\0' && *str2 != '\0') {
        if (*str1 > *str2)
            return 1;
        else if (*str1 < *str2)
            return -1;

        str1++;
        str2++;
    }

    if (*str1 == *str2) // Both string terminators
        return 0;

    if (*str1 != '\0') // First string has more characters, then it's greater lexicographically
        return 1;

    return -1;
}

int strncmp(const char *str1, const char *str2, size_t len)
{
    size_t i = 0;

    while (*str1 != '\0' && *str2 != '\0' && i < len) {
        if (*str1 > *str2)
            return 1;
        else if (*str1 < *str2)
            return -1;

        str1++;
        str2++;
        i++;
    }

    return 0;
}

size_t strlen(const char *str)
{
	size_t i = 0;

	for (; *str != '\0'; str++, i++)
		;

	return i;
}

char *strchr(const char *str, int c)
{
    while (*str != '\0') {
        if (*str == c)
            // Explicit cast to fix warning "return discards 'const' qualifier from pointer target type"
            return (char *)str;

        str++;
    }

    return NULL;
}

char *strrchr(const char *str, int c)
{
    int len = strlen(str) - 1;

	while (len >= 0) {
        if (str[len] == c)
            return (char *)str + len; // Another explicit cast

        len--;
    }

    return NULL;
}

char *strstr(const char *haystack, const char *needle)
{
    size_t i, len = strlen(needle);

    while (*haystack != '\0') {
        if (*haystack == *needle) {
            for (i = 0; i < len; i++)
                if (haystack[i] != needle[i])
                    break;

            if (i == len)
                return (char *)haystack; // Another explicit cast
        }

		haystack++;
	}

    return NULL;
}

char *strrstr(const char *haystack, const char *needle)
{
    size_t i = 0, j;
	size_t len_h = strlen(haystack), len_n = strlen(needle);

	haystack += len_h - 1; // Last char

    while (i < len_h) {
        if (*haystack == *needle) {
            for (j = 0; j < len_n; j++)
                if (haystack[j] != needle[j])
                    break;

            if (j == len_n)
                return (char *)haystack; // Another explicit cast
        }

		haystack--;
		i++;
	}

    return NULL;
}

void *memcpy(void *destination, const void *source, size_t num)
{
    size_t i;
    char *p = (char *)destination;

    for (i = 0; i < num && p != source; i++)
        p[i] = *((char *)source + i);

    return destination;
}

void *memmove(void *destination, const void *source, size_t num)
{
    size_t i;
    char *p = (char *)destination;
    const char *q = (const char *)source;

    if (p < q) {
        // Good to copy
        for (i = 0; i < num; i++)
            p[i] = q[i];
    } else {
        // Will overlap
        for (i = num; i > 0; i--)
            p[i - 1] = q[i - 1];
    }

    return destination;
}

int memcmp(const void *ptr1, const void *ptr2, size_t num)
{
    size_t i;
    const char *p = (const char *)ptr1;
    const char *q = (const char *)ptr2;

    for (i = 0; i < num - 1; i++)
        if (p[i] > q[i])
            return 1;
        else if (p[i] < q[i])
            return -1;

    return 0;
}

void *memset(void *source, int value, size_t num)
{
    size_t i;
    char *p = (char *)source;

    for (i = 0; i < num; i++)
        p[i] = value;

    return source;
}
