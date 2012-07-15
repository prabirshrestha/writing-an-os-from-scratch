#include <string.h>

void* memcpy(void* dest, const void* src, size_t count)
{
    const char *sp = (const char *)src;
    char *dp = (char *)dest;
    for(; count != 0; count--) *dp++ = *sp++;
    return dest;
}

void* memset(void* dest, int ch, size_t count)
{
    char *temp = (char *)dest;
    for( ; count != 0; count--) *temp++ = ch;
    return dest;
}

size_t strlen(const char *str)
{
    size_t retval;
    for(retval = 0; *str != '\0'; str++) retval++;
    return retval;
}