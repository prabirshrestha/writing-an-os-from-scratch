-include ../../../../Makefile.config

all: floppy.img
	cat boot1.bin boot15.bin > floppy.img

boot1.bin: boot1.out
	$(OBJCOPY) -O binary -j .text boot1.out boot1.bin

boot1.out: boot1.o
	$(LD) -o boot1.out boot1.o -Ttext 0x7c00
	$(OBJDUMP) -S boot1.out > boot1.asm

boot1.o:
	$(AS) -o boot1.o boot1.S

boot15.bin: boot15.out
	$(OBJCOPY) -O binary -j .text boot15.out boot15.bin

boot15.out: boot15.o
	$(LD) -o boot15.out boot15.o -Ttext 0x1000
	$(OBJDUMP) -S boot15.out > boot15.asm

boot15.o:
	$(AS) -o boot15.o boot15.S

clean:
	-rm -rf *.bin *.asm *.o *.lst *.out floppy.img

floppy.img: boot1.bin boot15.bin
	# create an empty image
	dd if=/dev/zero of=floppy.img bs=512 count=1440
	mkdosfs -F 12 floppy.img

	cat boot1.bin boot15.bin > boot.bin

	# copy stage 1 (mbr)
	dd if=boot1.bin of=floppy.img bs=512 seek=0 count=1 conv=notrunc

	# copy stage 1.5
	dd if=boot15.bin of=floppy.img bs=512 seek=1 count=1 conv=notrunc

qemu: floppy.img
	$(QEMU) -m 16 -fda floppy.img

qemu-gdb: floppy.img	# http://wiki.osdev.org/How_Do_I_Use_A_Debugger_With_My_OS
	@echo "***"
	@echo "*** Now run 'gdb'."
	@echo "***     you can connect using the following command"
	@echo "***         target remote localhost:1234"
	@echo "***     to set breakpoint at address 0x7c00"
	@echo "***         b *0x7c00"
	@echo "***    to set breakpoint using names load file first then set breakpoint"
	@echo "***         file boot.out"
	@echo "***         b main"
	@echo "***    to continue until next breakpoint"
	@echo "***         continue"
	@echo "***"
	$(QEMU) -s -S -m 256 -fda floppy.img
