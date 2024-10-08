bits 16
global _start

WIDTH equ 80
HEIGHT equ 25

KEYBOARD_PORT equ 0x60
CMOS_ADDRESS_PORT equ 0x70
CMOS_DATA_PORT equ 0x71
CMOS_REGISTER_SECONDS equ 0x00
SERIAL_OUT equ 0x3F8

TICK equ 0x046C

section .text
_start:
	;cli ; Disable interrupts

	; Setup registers
	xor eax, eax
	mov ds, ax ; Set Data Segment to 0
	mov ss, ax ; Set Stack Segment to 0
	mov ax, 0xB800 ; Set Extra Segment to videoram
	mov es, ax     ;
	mov sp, _start ; Set Stack Pointer to 0x7C00 (Over the code)

	; Set video mode
	mov ax, 0x0003
	int 0x10
	; Hide cursor
	mov ah, 0x01
	mov cx, 0x0F00
	int 0x10

	; Reset keyboard
	mov al, 0xFF
	out KEYBOARD_PORT, al

	; Seed random number generator
	mov al, CMOS_REGISTER_SECONDS
    out CMOS_ADDRESS_PORT, al
    in al, CMOS_DATA_PORT
    mov [rng], al

    ; Setup snake
    ; Accessing is: snake + idx * 2
    mov word [snake_len], 4
    mov word [snake], (WIDTH*4+8)*2
    mov word [snake+2], (WIDTH*4+9)*2
    mov word [snake+4], (WIDTH*4+10)*2
    mov word [snake+6], (WIDTH*4+11)*2
main:
    call print_snake
    mov ax, 1 ; wait one second
    call hold_on ; 
    ; mov word di, [snake_len]
    ; mov word [snake + edi*2], bx
    ; add word [snake_len], 1
    ; add bx, 2
    mov word bx, [snake_len]
    sub bx, 1
    add bx, bx
    mov ax, [snake+bx]
    ;movsx byte bx, [dirs+0]
    ;mov bx, -4
    ;add ax, bx
    cmp ax, WIDTH*2
    jl loose
    cmp ax, (WIDTH*HEIGHT-WIDTH)*2
    jg loose
    push ax
    and ax, 0x00FF
    cmp ax, 0x0000
    je loose
    cmp ax, 0x00FF
    je loose
    pop ax
    add word ax, [dirs+3*2]
    mov [snake+bx], ax
    ;add word [snake+6], 2 * WIDTH
    call print_snake
    jmp main
    ;jmp hlt
hlt:
	hlt
	jmp hlt

loose:
    mov dx, 0x3f8 ; Set up the serial port
	mov al, 'L'
	out dx, al
	mov al, 'o'
	out dx, al
	mov al, 's'
	out dx, al
	mov al, 't'
	out dx, al
    mov al, 10
	out dx, al
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

print_snake:
    pusha
    mov ax, `@\x0F`
	mov cx, [snake_len]
    mov si, snake
.print_snake:
    mov di, [si]
    stosw ; [ES:DI] = AX
    inc si
    inc si
    loop .print_snake
    popa
    ret

    ; AX: Amount of time to wait
hold_on:
    add ax, [TICK]
.wait:
    cmp [TICK], ax
    jne .wait
    ret

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

constants:
dirs: dw -WIDTH*2, 2, WIDTH*2, -2 ; Up, Right, Down, Left

times 510-($-$$) db 0
dw 0xAA55

section .bss

rng: resb 1
snake_len: resw 1
snake: resw 100
snake_dir: resw 1