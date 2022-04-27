.PHONY: build run clean
.DEFAULT: build
.PRECIOUS: %.elf

NAME := brainfuck
QEMU_DEBUG := -s -S
QEMU_FLAGS := -display none -serial pipe:../qemu
# -serial pipe:../out -serial stdio

build: ${NAME}.img

%.o: %.asm
	nasm -f elf32 -g3 -F dwarf -O0 $< -o $@

%.elf: %.o
	ld -Ttext=0x7C00 -m elf_i386 -o $@ $^

%.img: main.elf
	objcopy -O binary $< $@

run: ${NAME}.img
	@qemu-system-i386 \
		${QEMU_FLAGS} \
		-fda $< -boot a


debug: ${NAME}.img
	@qemu-system-i386 ${QEMU_FLAGS} ${QEMU_DEBUG} -hda $<
	# gdb --silent ${NAME}.elf \
	# 	-ex "set confirm off" \
	# 	-ex "set disassembly-flavor intel" \
	# 	-ex "target remote localhost:1234" \
	# 	-ex "break *0x7C00" \
	# 	-ex "break main" \
	# 	-ex "break hlt"

clean:
	rm -f *.o *.bin *.elf *.img