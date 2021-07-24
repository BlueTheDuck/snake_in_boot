- [NASM](#nasm)
- [Technical words](#technical-words)
  - [Data sizes](#data-sizes)
- [Modes](#modes)
  - [Real mode](#real-mode)
- [Interrupts](#interrupts)
    - [`0x10`, video services](#0x10-video-services)
    - [`0x14`, serial port](#0x14-serial-port)
- [Registers](#registers)
  - [General purpose](#general-purpose)
  - [Segment](#segment)
      - [Reference](#reference)
- [I/O Ports](#io-ports)
  - [Keyboard](#keyboard)
  - [Serial port](#serial-port)
  - [CMOS](#cmos)
  - [Examples](#examples)
- [Memory map](#memory-map)
  - [Bios Data Area](#bios-data-area)
- [Algorithms examples](#algorithms-examples)
  - [Print hex number](#print-hex-number)
  - [Linear Congruential Generator](#linear-congruential-generator)

# NASM
NASM is the assembler used in this project. 

# Technical words
## Data sizes
Sizes are encoded in the instructions themselves, following the this convention:
| Name   | Affix   | Size      | Declare   | Reserve   |
| ------ | ------- | --------- | --------- | --------- |
| Byte   | B       | 8 bits    | DB        | RESB      |
| Word   | W       | 16 bits   | DW        | RESW      |
| Double | D       | 32 bits   | DD        | RESD      |
| Quad   | Q       | 64 bits   | DQ        | RESQ      |


# Modes
## Real mode


# Interrupts
Called using `int ###`. Mostly taken from [Wikipedia - BIOS interrupt call]

### `0x10`, video services
Video settings. Takes parameters on `A` and `C`. (`A` selects subcommand). 

 * Subcommand `0x0003` sets the video mode
 * Subcommand `0x0103` sets the start and end scanline of the cursor. The low nibble of `CH` sets when to start drawing, while `CL` when to end. If `CH > CL` then nothing is drawn

### `0x14`, serial port
Reads or writes a single byte to the serial port. An alternative method exists: [I/O Ports](#io-ports)
(For some reason `ECX` **needs** to be zero?)

| `AH`   | Description                  |
| ------ | ---------------------------- |
| 0x01   | Initialize                   |
| 0x02   | Transmit character on `AL`   |
| 0x03   | Receive character            |
| 0x04   | Status                       |



# Registers
## General purpose

| Name   | 32 bits   | 16 bits     | 8 bits      |
| ------ | --------- | ----------- | ----------- |
| Acc.   | `EAX`     | `AX`        | `AH`/`AL`   |
| Base   | `EBX`     | `BX`        | `BH`/`BL`   |
| Count  | `ECX`     | `CX`        | `CH`/`CL`   |
| Data   | `EDX`     | `DX`        | `DH`/`DL`   |

* `_X` access the lower half of `E_X`
* `_H` access the higher half of `_X`, `_L` the lower

## Segment
(Only applies to [Real mode](#real-mode))
RAM is accessed using "segment registers", this is specified in docs with the syntax: `Segment Register:Index Register`. A simple equation determines the effective address that will be accessed:
`Physical Address = Segmen Register * 0x10 + Index Register`

Example:
```asm
mov ax, 0xB800
mov es, ax
mov edi, 5; EDI = Extended Data Index
stows ; Store AX at ES:EDI
```
`stows` will store `AX` at `0xB8005` (`0xB800 * 0x10 + 5`)

The following segment registers exist:
 - `CS` Code Segment
 - `DS` Data Segment
 - `SS` Stack Segment
 - `ES` Extra Segment
 - `FS` and `GS` general purpose

#### Reference
 - [OSDev - Segmentation]
 - [Assembly Language Tuts - Registers]

# I/O Ports
Written to, and read form using instructions `out` and `in`. A list of common ports can be found here: [OSDev - I/O Ports]

These opcodes can **only** be used with either an `imm8` or register `DX` for port selection. Data **must** come from (or go to) registers `AL`/`AX`/`EAX`. 

## Keyboard
Reading from `0x60` yields the scancode of the last key pressed (and will continue to until another is pressed)

Port map:
| Port | Operation  | Purpose |
| ---- | ---------- | ------- |
| 0x60 | Read/Write | Data    |
| 0x64 | Read       | Status  |
| 0x64 | Write      | Command |

Port 0x60 puts the last scancode, but can also be used to send commands to the PS/2 device. List here: [OSDev - PS/2 - Commands]

## Serial port
Since BIOS interrupts are **slow**, writing to the serial port is better done by interacting directly with the hardware. As a bonus, any of the available ports can be used with this method. [OSDev - Serial Ports]

## CMOS
The CMOS is a small micro controller that stores BIOS settings and more importantly, keeps (and updates) the time and date. It has its set of registers that can be accessed using port `0x70` for the address and `0x71` for the data.

This is an incomplete memory map, check [OSDev - CMOS - RTC] for full version:
| Register | Content  | Range        |
| -------- | -------- | ------------ |
| 0x00     | Seconds  | 0-59         |
| 0x02     | Minutes  | 0-59         |
| 0x04     | Hours    | 0-23 or 1-12 |
| 0x0A     | Status A |              |
| 0x0B     | Status B |              |

## Examples
```asm
in al, 0x60; Store scancode in `AL`
mov dx, 0x3f8 ; Set up the serial port. Can't access ports >0xFF without using `DX`
mov al, ':'   ; Only `AL`/`AX`/`EAX` can be used to transfer data
out dx, al
mov al, 'D'
; out 0x3f8,'(' <- Invalid
out dx, al
; Writes `:D` to first serial device
```

# Memory map
Some ranges and addresses in memory contain specific values or purposes. In [Real mode](#real-mode), 

## Bios Data Area

# Algorithms examples
This are general examples and useful algorithms to have

## Print hex number
Takes a byte in `AL` and prints it to the first [serial port](#serial-port). 

```asm
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
    add al, '@'-'9' ; if Num > 9, then we need to print 'A', 'B', ...
                    ; We need to achieve: `AL = Nibble - 9 + '@'`
                    ; By substracting 9 from `Nibble`, we are left with `1 <= Nibble <= 6`
                    ; by adding `Nibble - 9` to `'@'` we end with a letter `'A' <= letter <= 'F'`
.print_nibble_to_serial:
    out dx, al
    ret ; Will return to `.high_nibble_return` after printing highest nibble, or to caller after printing the lowest
```

## Linear Congruential Generator
Generates a pseudo-random number using the following formula:
$X_n = A * X_{n-1} + C \ (M)$
where `X_0` is the seed, `M` is the modulo (preferably a prime number) and `A` and `B` are both less than `M`.

While this is a very simple algorithm (and indeed very predictable), it is also fast (It only relies on multiplication, addition and modulo) and deterministic (The same seed will always produce the same output).

Here is an implementation using a global variable to keep track of the number:
```asm
    ; AX: Scratch
    ; Random number can be recovered from `[rng]` or `AX`
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
```
Here `rng` is a global variable (`rng: resb 1`) that initially holds the seed (A first write to `rng` is required to set the seed). After each call to `lcg`, `rng` will be updated with the new value. As a side effect, `AX` will also contain the new number.

[Wikipedia - BIOS interrupt call]: https://en.wikipedia.org/wiki/BIOS_interrupt_call
[Assembly Language Tuts - Registers]: https://www.assemblylanguagetuts.com/x86-assembly-registers-explained/
[OSDev - Segmentation]: https://wiki.osdev.org/Segmentation
[OSDev - I/O Ports]: https://wiki.osdev.org/I/O_Ports
[OSDev - PS/2 - Commands]: https://wiki.osdev.org/PS/2_Keyboard#Commands
[OSDev - Serial Ports]: https://wiki.osdev.org/Serial_Ports
[OSDev - CMOS - RTC]: https://wiki.osdev.org/CMOS#The_Real-Time_Clock