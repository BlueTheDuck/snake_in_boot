bits 16
global _start

BIOS_TTY_INT equ 0x14
BIOS_TTY_SEND equ 0x01
BIOS_TTY_REC equ 0x02

section .text
_start:
	;cli ; *DON'T* Disable interrupts

	; Setup registers
	xor eax, eax
	mov ds, ax ; Set Data Segment to 0
	mov ss, ax ; Set Stack Segment to 0
	mov ax, 0xB800 ; Set Extra Segment to videoram
	mov es, ax     ;
	mov sp, _start

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
	mov di, 0x0000
	mov si, 0x0000
.loop:
	mov byte al, [code + si] ; Get instruction
	mov byte dl, [tape + di] ; Get data
	cmp al, 0x00
	je hlt ; Hang if we're at the end of the code
.start_while:
	cmp al, '['
	jne .end_while
	cmp dl, 0x00
	jne .push_ret
	jmp end_while
.push_ret:
	push si
.end_while:
	cmp al, ']'
	jne .inc
	pop si
	jmp .loop
.inc:
	inc si
	cmp al, '+'
	jne .sub
	inc dl
.sub:
	cmp al, '-'
	jne .read
	dec dl
.read:
	cmp al, ','
	jne .store
	mov ah, BIOS_TTY_REC
	mov dx, 0
	int BIOS_TTY_INT
	mov dl, al
.store:
	mov byte [tape + di], dl ; Store byte into tape
.next:
	; region Check for tape move
	cmp al, '>'
	jne .prev
	inc di
.prev:
	cmp al, '<'
	jne .print
	dec di
.print:
	cmp al, '.'
	jne .end
	mov ah, BIOS_TTY_SEND
	mov al, dl
	xor dx, dx
	int BIOS_TTY_INT
.end:
	jmp .loop
hlt:
	hlt
	jmp hlt

end_while: ; When we enter here [code+si] points to '[', so cx will become 1 immediately
	; 
	xor cx, cx ; Counts brackets. +1 for '[' and -1 for ']'
	xor dx, dx
.loop: 
	cmp al, '['
	jne .not_open_loop
	inc cx
.not_open_loop:	
	cmp al, ']'
	jne .not_close_loop
	dec cx
.not_close_loop:
	inc si
	mov byte al, [code + si]
	cmp cx, 0
	jne .loop
	jmp main.loop ; [code+si] will point to the char next to ']'

code: db "+++[->+<]>>>-", 0

times 510-($-$$) db 0
dw 0xAA55


; 0x7E00
section .bss
tape:
	resb 256
