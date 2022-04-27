BIOS_TTY_INT equ 0x14
BIOS_TTY_SEND equ 0x01
BIOS_TTY_REC equ 0x02
BIOS_TTY_STATUS equ 0x03

;org 0x7C00
bits 16

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
	mov dx, 0x0 ; Use COM0
	mov al, 0x00
	mov ah, BIOS_TTY_STATUS
	int BIOS_TTY_INT
	mov ah, BIOS_TTY_REC
	int BIOS_TTY_INT
	mov al, 0x40 ; 0x40 = '@'
	mov ah, BIOS_TTY_SEND
	int BIOS_TTY_INT

	; Using ports DX and AX get dirty, but is faster:
	;mov dx, 0x3f8 ; Set up the serial port
	;%assign i 0
	;%rep 12
	;mov al, [txt+i]
	;out dx, al
	;%assign i i+1
	;%endrep
    
hlt:
	hlt
	jmp hlt

txt: db "Hello world!"

times 510-($-$$) db 0
dw 0xAA55

section .bss