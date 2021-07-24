org 0x7C00

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
	; Bad method with interrupts:
	; mov dx, 0x0
	; mov al, '1'
	; mov ah, 0x01
	; int 0x14

	; Good method using ports:
	mov dx, 0x3f8 ; Set up the serial port
	%assign i 0
	%rep 12
	mov al, [txt+i]
	out dx, al
	%assign i i+1
	%endrep
    
hlt:
	hlt
	jmp hlt

txt: db "Hello world!"

times 510-($-$$) db 0
dw 0xAA55

section .bss