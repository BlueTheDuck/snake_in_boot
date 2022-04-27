.PHONY: build run clean

NAME := game-1
QEMU_DEBUG := -s -S
QEMU_FLAGS := -serial stdio

${NAME}.img: main.asm
	@nasm -W+all -O0 -f bin -o $@ $<

build: ${NAME}.img
	
	
run: ${NAME}.img
	@qemu-system-i386 \
		${QEMU_FLAGS} \
		-fda $< -boot a


debug: ${NAME}.img
	@qemu-system-i386 ${QEMU_DEBUG} ${QEMU_FLAGS} -fda $< &
	gdb \
		-ex "set confirm off" \
		-ex "set disassembly-flavor intel" \
		-ex "target remote localhost:1234" \
		-ex "break *0x7C00" \
		-ex "c"

clean:
	rm -f *.o *.bin *.elf *.img