#ifndef PORT_H
#define PORT_H

__asm__(".code16gcc\n");

unsigned char inportb(unsigned short port);
void outportb(unsigned short port, unsigned char data);

#endif