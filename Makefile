all: os-image.bin

boot.o: boot.asm
	nasm -f bin boot.asm -o boot.o

start.o: start.asm
	nasm -f elf32 start.asm -o start.o

kernel.o: kernel.c
	gcc -m32 -ffreestanding -c kernel.c -o kernel.o

keyboard.o: keyboard.c
	gcc -m32 -ffreestanding -c keyboard.c -o keyboard.o

interrupts.o: interrupts.c
	gcc -m32 -ffreestanding -c interrupts.c -o interrupts.o

kernel.bin: start.o kernel.o keyboard.o interrupts.o
	ld -m elf_i386 -T linker.ld -o kernel.bin start.o kernel.o keyboard.o interrupts.o

os-image.bin: boot.o kernel.bin
	dd if=/dev/zero of=os-image.bin bs=512 count=2880
	dd if=boot.o of=os-image.bin conv=notrunc
	dd if=kernel.bin of=os-image.bin bs=512 seek=1 conv=notrunc

run: os-image.bin
	qemu-system-x86_64 -drive format=raw,file=os-image.bin

clean:
	rm -f *.o *.bin *.img *.iso os-image.bin kernel.bin
