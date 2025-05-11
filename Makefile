CC = gcc
AS = nasm
LD = ld

CFLAGS = -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector \
         -nostartfiles -nodefaultlibs -Wall -Wextra -c \
         -fno-exceptions -ffreestanding -O0 -g3 \
         -fno-omit-frame-pointer

LDFLAGS = -melf_i386 -nostdlib -T linker.ld --oformat binary -Map=kernel.map

OBJECTS = kernel_entry.o kernel.o io.o

.PHONY: all clean run

all: clean os-image

boot.bin: boot.asm
	$(AS) -f bin boot.asm -o boot.bin -l boot.lst

kernel_entry.o: kernel_entry.asm
	$(AS) -f elf32 kernel_entry.asm -o kernel_entry.o -l kernel_entry.lst

%.o: %.c
	$(CC) $(CFLAGS) $< -o $@

kernel.bin: $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o kernel.bin
	objdump -M intel -d kernel_entry.o > kernel_entry.dump
	objdump -M intel -d kernel.o > kernel.dump

os-image: boot.bin kernel.bin
	cat boot.bin kernel.bin > os-image.bin

run: os-image
	qemu-system-i386 -fda os-image.bin -d cpu_reset,guest_errors -no-reboot -monitor stdio

clean:
	rm -f *.o *.bin *.lst *.dump *.map
