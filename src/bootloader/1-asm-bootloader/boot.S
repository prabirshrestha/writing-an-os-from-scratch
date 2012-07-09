# http://www.websofia.com/2011/10/writing-your-own-boot-loader-for-a-toy-operating-system-1/
# http://www.websofia.com/2011/10/writing-your-own-bootloader-for-a-toy-operating-system-2/
# http://www.websofia.com/2012/04/writing-your-own-bootloader-for-a-toy-operating-system-3/

.code16						# 16 bit code generation
							# Since all intel based start up with 16-bit instructions,
							# we won't be able to write 32 bit code yet. 

.intel_syntax noprefix		# instruct GNU assembler that we’ll be using Intel syntax
							# (e.g. mov ax, 1 instead of movw $1, %ax – some prefer the latter

.text
.org 0x0					# the origin of our code will be 0×0, 
							# i.e. all absolute addresses start at 0×0, which will be convenient.

.global main				# making entry point visible to the linker

main:
	jmp main				# infinite loop

.fill (510-(.-main)), 1, 0  # Pad with nulls up to 510 bytes (exclude boot magic)
BootMagic:  .int 0xAA55     # magic word for BIOS
