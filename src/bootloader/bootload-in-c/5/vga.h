#ifndef VGA_H
#define VGA_H

__asm__(".code16gcc\n");

int vga_cursor_x;
int vga_cursor_y;

void vga_cls();
void vga_update_cursor();
void vga_scroll();

#endif