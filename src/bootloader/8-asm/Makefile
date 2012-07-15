-include ../../../Makefile.config

all: floppy.img

boot.bin: boot.out
	$(OBJCOPY) -O binary -j .text boot.out boot.bin

boot.out: boot.o
	$(LD) -o boot.out boot.o -Ttext 0x7c00
	$(OBJDUMP) -S boot.out > boot.asm

boot.o:
	$(AS) -o boot.o boot.S

floppy.img: boot.bin
	# create an empty image
	dd if=/dev/zero of=floppy.img bs=512 count=1440
	mkdosfs -F 12 floppy.img
	# copy mbr
	dd if=boot.bin of=floppy.img bs=1 count=512 conv=notrunc

	# mount floppy
	sudo mount -o loop floppy.img /media/floppy/

	# unmount floppy
	sudo umount /media/floppy/	

qemu: floppy.img
	$(QEMU) -m 256 -fda floppy.img

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

clean:
	rm boot.o boot.bin boot.out boot.asm floppy.img
