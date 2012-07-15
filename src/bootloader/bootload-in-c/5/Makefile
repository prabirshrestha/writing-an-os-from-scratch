-include ../../../../Makefile.config

all: floppy.img

boot.o: boot.c
	$(CC) $(CLFAGS) -nostdinc -fno-builtin -I./include  -c -o $@ $^

boot.bin: boot.o
	$(LD) $(LDFLAGS) -T boot.ld -o $@.out $^
	objcopy -O binary $@.out $@

floppy.img: boot.bin
	dd if=boot.bin of=floppy.img bs=512 count=2880

qemu: floppy.img
	$(QEMU) -m 256 -hda floppy.img

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
	$(QEMU) -s -S -m 256 -hda floppy.img

clean:
	rm *.o *.out *.bin *.img