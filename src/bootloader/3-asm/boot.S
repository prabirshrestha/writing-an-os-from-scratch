# references:
#   http://www.freebsd.org/doc/en/books/arch-handbook/book.html
#   http://www.websofia.com/2011/10/writing-your-own-boot-loader-for-a-toy-operating-system-1/

# During boot, certain PC registers are set to a particurlar value.
# instruction pointer (ip) register is set to 32-bit value of 0xfffffff0
#   ip register points to the code to be executed.
# cr0 register set to 0
#   it is a 32-bit control register
#   one of cr0's bit indicates whether the processor is runing in real or protected mode.
#   during boot time this bit is cleared so it always boots in real mode.
# value of 0xfffffff0 is slightly less then 4gb.

# BIOS and its chip on motherboard has a small amount of ROM which contains
# various low-level routines that are specific to the hardware suplied with motherboard.
# So, the processor will first jump to the address 0xfffffff0,
# which really resides in the BIOS's memory.
# Usually this address contains a jump instruction to the BIOS's POST routines.

# POST stands for Power On Self Test.
# This is a set of routines including the
#   memory check,
#   system bus check
#   and other low-level stuff
# so that the CPU can initialize the computer properly.
# The important step on this stage is determining the boot device.
# All modern BIOS's allow the boot device to be set manually, so you can boot from a floppy, CD-ROM, harddisk etc.

# The very last thing in the POST is the INT 0x19 instruction
# That instruction reads 512 bytes from the first sector of boot device into the memory at address 0x7c00
# This is first sector is also called MBR or Master Boot Record

.code16                     # 16 bit code generation
                            # Since all intel based start up with 16-bit instructions,
                            # we won't be able to write 32 bit code yet. 

.intel_syntax noprefix      # instruct GNU assembler that we’ll be using Intel syntax
                            # (e.g. mov ax, 1 instead of movw $1, %ax – some prefer the latter

.text                       # code segment
.org 0x0                    # the origin of our code will be 0×0,
                            # i.e. all absolute addresses start at 0×0, which will be convenient.

.global main                # making entry point visible to the linker

main:
    jmp stage1_start        # this is the main entry point of our code which corresponds to the first byte
    nop                     # of actual output when assembled The code under "main" simply jumps over the
                            # BPB and EBPB located at offset 0×3, resuming execution at the label stage1_start. 

stage1_start:
    jmp stage1_start

.fill (510-(.-main)), 1, 0  # Pad with nulls up to 510 bytes (exclude boot magic)

BootMagic:  .int 0xAA55     # magic word for BIOS
                            # if the last word of bootsector contains 0xAA55,
                            # then this disk is treated by BIOS as bootable
