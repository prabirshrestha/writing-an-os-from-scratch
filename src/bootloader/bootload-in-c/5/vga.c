#include "vga.h"
#include "port.h"

void vga_cls()
{
    unsigned char *videoMemory = (unsigned char*)0xb8000; // char -> byte
    unsigned int i = 0;
    // text mode in x86 in 80 columns X 25 rows and each character needs 2 bytes.
    // first byte is the character
    // second byte is the attribute which controls color and blinking
    while(i < 80 * 25 * 2)
    {
        videoMemory[i] = ' ';	// write whitespace to video memory at location i
        ++i;					// next byte
        videoMemory[i] = 0x07;	// 0x07 specifies black background with white non-blinking text.
        ++i;
    }

    vga_cursor_x = 0;
    vga_cursor_y = 0;

    // vga_update_cursor();
}

// void vga_update_cursor()
// {
//     // Set cursor position
//     // 0x3D4: index register (specify read/write)
//     // 0x3D5: data register (actuall read/write value)

//     // these register is called CRTC register and contains 
//     // functions to move the cursor position, scroll the screen 
//     // and some other things.

//     // Cursor register is divided into two. 14 and 15 (0xE and oxF in hex)
//     // This is because one index is just 8 bits long and with that,
//     // you could only specify 256 different positions. 80x25 is a larger than that,
//     // so it was divided into two registers. 
//     // Register 14 is the MSB of the cursor offset (from the start of the video memory) 
//     // and 15 the LSB.
//     outportb(0x3D4, 14);
//     outportb(0x3D5, vga_cursor_x);
//     outportb(0x3D4, 15);
//     outportb(0x3D5, vga_cursor_x);
// }

// void vga_scroll()
// {

// }
