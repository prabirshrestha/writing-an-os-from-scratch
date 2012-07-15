#ifndef STRING_H
#define STRING_H

#include <stddef.h>

void* memcpy(void* dest, const void* src, size_t count);
void* memset(void* dest, int ch, size_t count);

size_t strlen(const char *str);

#endif