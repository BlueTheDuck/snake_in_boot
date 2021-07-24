org 0x7C00

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
.echo_kb: ; Send ECHO to KB, loop until we receive 0xEE
	mov al, 0xEE
	out 0x60, al
	in al, 0x60
	cmp al, 0xEE
	jne .echo_kb

	mov dx, 0x3f8 ; Set up the serial port
	%assign i 0
	%rep 4
	mov al, [startup_ok+i]
	out dx, al
	%assign i i+1
	%endrep
main:
	mov dx, 0x3f8 ; Set up the serial port
.read_loop:
	in al, 0x60

	%assign i 0
	%rep 4
	cmp al, [scans+i]
	cmove ax, [keys+i]
	je .write
	%assign i i+1
	%endrep

	jmp .read_loop
.write:
	out dx, al
	jmp .read_loop

hlt:
	hlt
	jmp hlt

txt: db "Init"
scans: db 17,30,31,32
keys: db "WASD"
startup_ok: db "OK 1"


times 510-($-$$) db 0
dw 0xAA55

section .bss