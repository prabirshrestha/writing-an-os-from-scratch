.code16                     # 16 bit code generation
                            # Since all intel based start up with 16-bit instructions,
                            # we won't be able to write 32 bit code yet. 

.intel_syntax noprefix      # instruct GNU assembler that we’ll be using Intel syntax
                            # (e.g. mov ax, 1 instead of movw $1, %ax – some prefer the latter


.text                       # code segment
.org 0x0                    # the origin of our code will be 0×0,
                            # i.e. all absolute addresses start at 0×0, which will be convenient.


# main program
main:
  # display B
  mov ah,0x0E 
  mov bh,0x00 
  mov al,66
  int 0x10

hang:
	jmp hang

# not required by stage 1.5 loader
.fill (510-(.-main)), 1, 0  # Pad with nulls up to 510 bytes (exclude boot magic)

BootMagic:  .int 0xAA55     # magic word for BIOS
                            # if the last word of bootsector contains 0xAA55,
                            # then this disk is treated by BIOS as bootable
