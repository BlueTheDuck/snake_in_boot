bits 16
global _start
extern halt

BIOS_TTY_INT equ 0x14
BIOS_TTY_SEND equ 0x01
BIOS_TTY_REC equ 0x02
BIOS_TTY_STATUS equ 0x03

section .text
_start:
	cli ; Disable interrupts

	; Setup
	xor eax, eax
	mov ds, ax ; Set Data Segment to 0
	mov ss, ax ; Set Stack Segment to 0
	mov ax, 0xB800 ; Set Extra Segment to videoram
	mov es, ax     ;
	mov sp, 0x7C00
main:
	; Using interrupts only AX gets dirty:
ints:
	mov dx, 0x0 ; Use COM0
	mov al, 0x00
	mov ah, BIOS_TTY_STATUS
	int BIOS_TTY_INT
	mov ah, BIOS_TTY_REC
	int BIOS_TTY_INT
	%assign i 0
	%rep 13
	mov al, [txt+i] ; 0x40 = '@'
	mov ah, BIOS_TTY_SEND
	int BIOS_TTY_INT
	%assign i i+1
	%endrep

ports:
	; Using ports DX and AX get dirty, but is faster:
	mov dx, 0x3f8 ; Set up the serial port
	%assign i 0
	%rep 13
	mov al, [txt+i]
	out dx, al
	%assign i i+1
	%endrep
    call halt

txt: db "Hello world!", 10

times 510-($-$$) db 0
dw 0xAA55

section .bss