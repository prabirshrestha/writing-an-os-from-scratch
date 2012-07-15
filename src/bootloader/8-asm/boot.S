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

# OEM Parameter Block / BIOS Parameter Block
bios_parameter_block:
    iOEM:           .ascii  "PrabirOS"      # OEM String
    iSectSize:      .word   0x200           # bytes per sector (512 in decimal)
    iClustSize:     .byte   1               # sectors per FAT cluster
    iResSect:       .word   1               # number of reserved sectors
    iFatCnt:        .byte   2               # number of FAT copies
    iRootSize:      .word   224             # size of root directory
    iTotalSect:     .word   2880            # total number of sectors if over 32 MB
    iMedia:         .byte   0xF0            # Double sided, 18 sectors per track (240 in decimal)
    iFatSize:       .word   9               # sectors per FAT
    iTrackSect:     .word   18              # sectors per track
    iHeadCnt:       .word   2               # number of read-write heads
    iHiddenSect:    .int    0               # number of hidden sectors
    iSect32:        .int    0               # number of sectors for over 32 MB
    iBootDrive:     .byte   0               # holds drive that the boot sector came from
    iReserved:      .byte   0               # reserved, empty
    iBootSign:      .byte   0x29            # extended boot sector signature
    iVolID:         .ascii  "seri"          # disk serial
    acVolumeLabel:  .ascii  "MYVOLUME   "   # volume label
    acFSType:       .ascii  "FAT12   "      # file system type

# we’ll want to call the functions various times in the other boot code that we write. 
# They are not part of the main body of code. That is why they are placed before the stage1_start label,
# so that execution will jump over them.

# Initialize various segments:
# - The boot sector is loaded by BIOS at 0:7C00 (CS = 0)
# - CS, DS and ES are set to zero.
# - Stack point is set to 0x7C00 and will grow down from there.
# - Interrupts may not act now, so they are disabled.
.macro mInitSegments
    cli                     # block all maskable interrupts (does not block NMI - non-maskable interrupts)
    mov  iBootDrive, dl     # save what drive we booted from (should be 0x0)
                            # BIOS places the number of the boot drive in the DL register. We store it in our BPB for later use.
    # We set ES = DS = SS = CS = 0×0, and make the stack grow down from 0x7C00 (our boot loader was loaded at 0x7C00)
    mov  ax, cs             # CS = 0x0, since that's where boot sector is (0x07c00)
    mov  ds, ax             # DS = CS = 0x0
    mov  es, ax             # ES = CS = 0x0
    mov  ss, ax             # SS = CS = 0x0
    mov  sp, 0x7C00         # Stack grows down from offset 0x7C00 toward 0x0000.
    sti                     # enable interrupt
.endm

# Printing on screen
# function that uses BIOS interrupt 0×10, sub-function 9 to print characters to the screen
# The calling code must point DS:SI to the null-terminated string to be printed
.func WriteString
 WriteString:
    lodsb                   # load byte at ds:si into al (advancing si)
    or     al, al           # test if character is 0 (end)
    jz     WriteString_done # jump to end if 0.
    mov    ah, 0xe          # Subfunction 0xe of int 10h (video teletype output)
    mov    bx, 9            # Set bh (page nr) to 0, and bl (attribute) to white (9)
    int    0x10             # call BIOS interrupt
    jmp    WriteString      # Repeat for next character

 WriteString_done:
    retw
.endfunc

# code that prints a "Press any key to reboot" message, waits for a keystroke, and reboots the machine.
.func Reboot
 Reboot:
    lea    si, rebootmsg # Load address of reboot message into si
    call   WriteString   # print the string
    xor    ax, ax        # subfuction 0
    int    0x16          # call bios to wait for key
    .byte  0xEA          # machine language to jump to FFFF:0000 (reboot)
    .word  0x0000
    .word  0xFFFF
.endfunc

# The main stage1 start
stage1_start:
    mInitSegments

    # Display the loading message
    lea  si, loadmsg
    call WriteString

    # Reset disk system.
    # Jump to bootFailure on error.
    mov  dl, iBootDrive  # drive to reset
    xor  ax, ax          # subfunction 0
    int  0x13            # call interrupt 13h
    jc   bootFailure     # display error message if carry set (error)  

    # end of stage1, for now call reboot
    call Reboot

bootFailure:
  lea  si, diskerror
  call WriteString
  call Reboot

# PROGRAM DATA
loadmsg:    .asciz "Loading Prabir's OS..."
diskerror:  .asciz "Disk error"
rebootmsg:  .asciz "Press any key to reboot"

.fill (510-(.-main)), 1, 0  # Pad with nulls up to 510 bytes (exclude boot magic)

BootMagic:  .int 0xAA55     # magic word for BIOS
                            # if the last word of bootsector contains 0xAA55,
                            # then this disk is treated by BIOS as bootable
