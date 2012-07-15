asm (".code16gcc");			/* 	16 bit code generation
                            	Since all intel based start up with 16-bit instructions,
                            	we won't be able to write 32 bit code yet. */

asm ("jmp main");

#define WHITE_TEXT 0x07     // white on black text

void main();

unsigned char in(unsigned short port);
void out(unsigned short port, unsigned char data);
void set_cursor(int x, int y);
void clear_screen();        // clear screen

void hang();

#include <string.h>

void main()
{
    size_t x;
    char *hello = "hello world";
    x = strlen(hello);
	clear_screen();
	hang();
}

void hang()
{
	asm("cli");
	asm("hlt");
	hang();
}

unsigned char in(unsigned short port)
{
    unsigned char result;

    // "=a" (result) means: put AL register in variable result when finished
    // "d" (port) means: load EDX with port

    // first write the assembly, then specificy the input and output
    // The input is our port and the output is our value recieved from in.
    // The two %% says that this is a register
    // If we don't have any inputs or outputs, only one % is required
    // After the first ':', the outputs are lined up.
    // The "=a" (result), tells the compiler to put result = EAX
    // If I'd write "=b" instead, then result = EBX.
    // If you want more than one output, just put a ',' and write the next and so on
    // Now to the outputs. "d" specifies that EDX = port
    // Same as output, but without the '='
    __asm__ ("in %%dx, %%al" : "=a" (result) : "d" (port));
    return result;
}

void out(unsigned short port, unsigned char data)
{
    // "a" (data) means: load EAX with data
    // "d" (port) means: load EDX with port

    // first write the assembly, then specificy the input and output
    //  Same as for in(), but with no outputs and two inputs instead.
   __asm__ ("out %%al, %%dx" : : "a" (data), "d" (port));
}

void set_cursor(int x, int y)
{
    // Set cursor position
    // 0x3D4: index register (specify read/write)
    // 0x3D5: data register (actuall read/write value)

    // these register is called CRTC register and contains 
    // functions to move the cursor position, scroll the screen 
    // and some other things.

    // Cursor register is divided into two. 14 and 15 (0xE and oxF in hex)
    // This is because one index is just 8 bits long and with that,
    // you could only specify 256 different positions. 80x25 is a larger than that,
    // so it was divided into two registers. 
    // Register 14 is the MSB of the cursor offset (from the start of the video memory) 
    // and 15 the LSB.
    out(0x3D4, 14);
    out(0x3D5, x);
    out(0x3D4, 15);
    out(0x3D5, y);
}

void clear_screen()
{
    unsigned char *videoMemory = (unsigned char*)0xb8000; // char -> byte
    unsigned int i = 0;
    // text mode in x86 in 80 columns X 25 rows and each character needs 2 bytes.
    // first byte is the character
    // second byte is the attribute which controls color and blinking
    while(i < 80 * 25 * 2)
    {
        videoMemory[i] = ' ';             // write whitespace to video memory at location i
        ++i;                              // next byte
        videoMemory[i] = WHITE_TEXT;      // 0x07 specifies black background with white non-blinking text.
        ++i;
    }

    set_cursor(0, 0);
}
