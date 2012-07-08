-include ../../../Makefile.config

all: boot.bin

boot.bin: boot.o
	$(LD) -o boot.out boot.o -Ttext 0x7c00
	$(OBJCOPY) -O binary -j .text boot.out boot.bin

boot.o:
	$(AS) -o boot.o boot.S

clean:
	rm boot.o boot.bin boot.out
