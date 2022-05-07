bits 16
global _start

WIDTH equ 80 ; 80 characters / 160 bytes
HEIGHT equ 48 ; 48 lines

section .text
_start:
	cli ; Disable interrupts

	; Setup registers
	xor eax, eax
	mov ds, ax ; Set Data Segment to 0
	mov ss, ax ; Set Stack Segment to 0
	mov ax, 0xB800 ; Set Extra Segment to videoram
	mov es, ax     ;
	mov sp, 0x7C00

	; Set video mode
	mov ax, 0x0003
	int 0x10
	; Hide cursor
	mov ah, 0x01
	mov cx, 0x0F00
	int 0x10

	; Reset keyboard
	mov al, 0xFF
	out 0x60, al

main:
	mov cx, WIDTH*HEIGHT
	mov di, 0 ; ALIGN(2)!!!
	mov ax, `\xDB\x02`
	rep stosw ; Repeted store 16-bit values (AX) to video memory ([ES:DI]). CX is decremented until 0.

    mov di, 0
    mov ax, `A\x0F` ; White 'A'; LE
    stosw ; <- Store 'A' in video memory (ES*0x10 + DI), then increment DI
    mov di, 0 ; <- Reset DI to point to first character in video memory. If we don't, then next cmp fails
    cmp byte [es:di], 'A' ; Compare first character in video memory to 'A'
    cmove ax, [letters+1] ; If 'A', load 'B' into AL
    mov ah, 0xF
    stosw ; Store 'B' in video memory (ES*0x10 + DI), then increment DI

	
	
	

hlt:
	hlt
	jmp hlt

letters: db 'A', 'B', 'C', 'D', 'E', 'F'


times 510-($-$$) db 0
dw 0xAA55

section .bss