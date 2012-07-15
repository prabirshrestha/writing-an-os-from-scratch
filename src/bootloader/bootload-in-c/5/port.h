#ifndef PORT_H
#define PORT_H

unsigned char inportb(unsigned short port);
void outportb(unsigned short port, unsigned char data);

#include "port.c"

#endif