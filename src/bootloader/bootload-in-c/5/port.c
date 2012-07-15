#include "port.h"

unsigned char inportb(unsigned short port)
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
}

void outportb(unsigned short port, unsigned char data)
{
	// "a" (data) means: load EAX with data
	// "d" (port) means: load EDX with port

	// first write the assembly, then specificy the input and output
	//  Same as for in(), but with no outputs and two inputs instead.
	__asm__ ("out %%al, %%dx" : : "a" (data), "d" (port));
}
