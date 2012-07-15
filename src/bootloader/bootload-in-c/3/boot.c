asm (".code16gcc");			/* 	16 bit code generation
                            	Since all intel based start up with 16-bit instructions,
                            	we won't be able to write 32 bit code yet. */

asm ("jmp main");

#define WHITE_TEXT 0x07		// white on black text

void main();
void hang();

// perfix with b_ means bootloader similar to k_ (my own naming standard)
void b_clear_screen();		// clear screen

void
main()
{
	b_clear_screen();
	hang();
}

void
hang()
{
	asm("cli");
	asm("hlt");
	hang();
}

void
b_clear_screen()
{
	char *videoMemory = (char*)0xb8000; // char -> byte
	unsigned int i = 0;
	// text mode in x86 in 80 columns X 25 rows and each character needs 2 bytes.
	// first byte is the character
	// second byte is the attribute which controls color and blinking
	while(i < 80 * 25 * 2) 
	{
		videoMemory[i] = ' '; 			// write whitespace to video memory at location i
		++i; 							// next byte
		videoMemory[i] = WHITE_TEXT;	// 0x07 specifies black background with white non-blinking text.
		++i;
	}
}
