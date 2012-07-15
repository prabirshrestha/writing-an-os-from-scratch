asm (".code16gcc");			/* 	16 bit code generation
                            	Since all intel based start up with 16-bit instructions,
                            	we won't be able to write 32 bit code yet. */

asm ("jmp main");

#include "vga.h"

void main()
{
    vga_cls();
    while(1);
}
