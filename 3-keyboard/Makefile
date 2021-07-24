.PHONY: build run clean

NAME := keyboard
QEMU_DEBUG := -s -S
QEMU_FLAGS := -serial stdio

${NAME}.img: main.asm
	@nasm -O0 -f bin -o $@ $<

run: ${NAME}.img
	@qemu-system-x86_64 \
		${QEMU_FLAGS} \
		-fda $< -boot a


debug: ${NAME}.img
	@qemu-system-x86_64 ${QEMU_DEBUG} ${QEMU_FLAGS} -fda $< &
	gdb \
		-ex "set confirm off" \
		-ex "set disassembly-flavor intel" \
		-ex "target remote localhost:1234" \
		-ex "break *0x7C00" \
		-ex "c"

clean:
	rm -f *.o *.bin *.elf *.img