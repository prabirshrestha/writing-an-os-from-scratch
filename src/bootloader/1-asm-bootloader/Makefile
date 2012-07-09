-include ../../../Makefile.config

all: floppy.img

boot.bin: boot.out
	$(OBJCOPY) -O binary -j .text boot.out boot.bin

boot.out: boot.o
	$(LD) -o boot.out boot.o -Ttext 0x7c00

boot.o:
	$(AS) -o boot.o boot.S

floppy.img: boot.bin
	dd if=boot.bin of=floppy.img bs=512 count=2880

qemu: floppy.img
	$(QEMU) -hda floppy.img

clean:
	rm boot.o boot.bin boot.out floppy.img
