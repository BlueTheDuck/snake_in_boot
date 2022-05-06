.PHONY: build run clean
.PRECIOUS: %.elf %.bin

QEMU_DEBUG := -s -S
QEMU_FLAGS := -serial stdio -boot a
NAME := hello

%.o: %.asm
	@nasm -O0 -f elf32 -g3 -F dwarf $< -o $@

%.elf: %.o
	@ld -nostdlib -Ttext=0x7C00 -m elf_i386 -o $@ $<

%.bin: %.elf
	@objcopy -O binary $< $@

%.sym: %.elf
	@objdump -t -C $< > ${NAME}.dump.sym

run: ${NAME}.bin
	@qemu-system-i386 ${QEMU_FLAGS} -fda $<

run-debugger: ${NAME}.bin
	@qemu-system-i386 ${QEMU_FLAGS} ${QEMU_DEBUG} -fda $<

debug: ${NAME}.bin
	@qemu-system-i386 ${QEMU_FLAGS} ${QEMU_DEBUG} -fda $< &
	gdb \
		-ex "set confirm off" \
		-ex "set disassembly-flavor intel" \
		-ex "target remote localhost:1234" \
		-ex "file ${NAME}.elf" \
		-ex "break _start" \
		-ex "c"

clean:
	rm -f *.o *.bin *.elf *.img *.sym