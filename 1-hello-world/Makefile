.PHONY: build run clean

QEMU_DEBUG := -s -S

hello.img: hello.asm
	@nasm -O0 -f bin -o $@ $<

run: hello.img
	@qemu-system-x86_64 \
		-serial stdio \
		-fda $< -boot a


debug: hello.img
	@qemu-system-x86_64 ${QEMU_DEBUG} -fda $< &
	gdb \
		-ex "set confirm off" \
		-ex "set disassembly-flavor intel" \
		-ex "target remote localhost:1234" \
		-ex "break *0x7C00" \
		-ex "c"

clean:
	rm -f *.o *.bin *.elf *.img