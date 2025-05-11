CC = i686-elf-gcc
AS = nasm
LD = i686-elf-ld

CFLAGS = -ffreestanding -O2 -Wall -Wextra -fno-exceptions -m32
LDFLAGS = -T linker.ld -nostdlib

OBJECTS = kernel_entry.o kernel.o io.o

all: os-image

boot.bin: boot.asm
	$(AS) -f bin boot.asm -o boot.bin

kernel_entry.o: kernel_entry.asm
	$(AS) -f elf32 kernel_entry.asm -o kernel_entry.o

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

kernel.bin: $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o kernel.bin

os-image: boot.bin kernel.bin
	cat boot.bin kernel.bin > os-image.bin

clean:
	rm -f *.o *.bin

.PHONY: all clean
