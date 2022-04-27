;org 0x7C00
bits 16

%macro declstr 1
	%strlen c %1
	dd c
	db %1
%endmacro

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

	; Set video mode
	mov ax, 0x0003
	int 0x10

	; Hide cursor
	mov ax, 0x0103
	mov ch, 0x0F ; By having `CH > CL` the
	mov cl, 0x00 ; cursor becomes invisible
	int 0x10

	mov edx, 0

	mov ah, 0x0E
	
	;mov esi, txt+4 ; Data source
	;mov edi, 0x0 ; Offset into videoram
	;mov ecx, [txt] ; Size of data
	;call print
	mov esi, txt+4
	mov ecx, [txt]
	call write
	mov esi, txt+4
	mov ecx, [txt]
	call write
	mov esi, txt+4
	mov ecx, [txt]
	call write
hlt:
	jmp hlt

	; AH: Style
	; ESI: Source
	; ECX: Length
write:
	mov edi, [pos]
	add [pos], ecx
	add [pos], ecx
	; AH: Style
	; EDI: Destination
	; ESI: Source
	; ECX: Length
print:
	pushf
	cld ; Set direction flag
.print_loop:
	lodsb ; Load AL with DS * 0x10 + ESI
	stosw ; Store AX in ES * 0x10 + EDI
	loop .print_loop ; Decrement C, and loop if C != 0
.print_end:
	popf
	ret

txt:
	declstr "Hello world!"

times 510-($-$$) db 0
dw 0xAA55

section .bss
pos: resb 1

