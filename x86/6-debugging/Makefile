.PHONY: build run clean
.DEFAULT: build

QEMU_DEBUG := -s -S

build: main.img

%.o: %.asm
	nasm -f elf32 -g3 -F dwarf -O0 $< -o $@

%.elf: %.o
	ld -Ttext=0x7C00 -m elf_i386 -o $@ $^

%.img: %.elf
	objcopy -O binary $< $@

run: main.img
	@qemu-system-i386 \
		-serial stdio \
		-fda $< -boot a


debug: main.img
	@qemu-system-i386 ${QEMU_DEBUG} -hda $< &
	gdb main.elf \
		-ex "set confirm off" \
		-ex "set disassembly-flavor intel" \
		-ex "target remote localhost:1234" \
		-ex "break *0x7C00" \
		-ex "c"

clean:
	rm -f *.o *.bin *.elf *.img