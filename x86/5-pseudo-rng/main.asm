org 0x7C00

CMOS_ADDRESS_REGISTER equ 0x70
CMOS_DATA_REGISTER equ 0x71
CMOS_REGISTER_SECONDS equ 0x00
SERIAL_OUT equ 0x3F8
TIMER equ 0x046C


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
    mov al, CMOS_REGISTER_SECONDS
    out CMOS_ADDRESS_REGISTER, al
    in al, CMOS_DATA_REGISTER
    mov [rng], al
    mov cl, 0x00
    mov dx, SERIAL_OUT
.print_loop:
    ;call lcg
    ;call print_num
    ;add cl,1
    ;cmp cl, 0x00
    ;jne .print_loop

    ; wtf: 0x0000046C - 0x00000470
xxx:
    mov word bx, [0x046C]
    mov al, bh
    call print_num    
    mov al, bl
    call print_num    
    mov al, 0x0A
    out dx, al
    add bx, 0x1
.wait:
    cmp bx, [0x046C]
    jne .wait
    jmp xxx
hlt:
	hlt
	jmp hlt


%define M 3847
%define A 227
%define C 47
lcg:
    mov ax, A
    mul byte [rng]
    add ax, C
.mod_M_loop:
    cmp ax, M
    jl .lcg_end
    sub ax, M
    jmp .mod_M_loop
.lcg_end:
    mov [rng], ax
    ret
%undef M
%undef A
%undef C

    ; AL: Byte to print. 0 <= AL <= 0xFF
    ; DX: Serial out to use
    ; AX, CX: Scratch
    ; This function is only 27 bytes long
print_num:
    mov ah, al
    and ax, 0x0FF0 ; AH has the low nibble, AL has the high nibble
    shr al, 4
    add ax, '00' ; Convert both nibbles to ASCII
    push word .high_nibble_return
    jmp .print_nibble
.high_nibble_return:
    mov al, ah
.print_nibble:
    cmp al, '9' ; If Num <= 9, then we can print it
    jbe .print_nibble_to_serial ; Skip next line
    add al, '@'-'0'-9 ; if Num > 9, then we need to print 'A', 'B', ...
                      ; By substracting 9 from `Nibble`, we are left with `1 <= Nibble <= 6`
                      ; by adding `Nibble - 9` to `'@'` we end with a letter `'A' <= letter <= 'F'`
.print_nibble_to_serial:
    out dx, al
    ret

    


times 510-($-$$) db 0
dw 0xAA55

section .bss
rng: resb 1