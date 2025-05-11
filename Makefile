CC = gcc
AS = nasm
LD = ld

# Флаги для компиляции без стандартной библиотеки
CFLAGS = -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector \
         -nostartfiles -nodefaultlibs -Wall -Wextra -c \
         -fno-exceptions -ffreestanding -O0 -g

# Флаги линковки
LDFLAGS = -T linker.ld -melf_i386 -nostdlib --oformat binary

OBJECTS = kernel_entry.o kernel.o io.o

all: os-image

boot.bin: boot.asm
	$(AS) -f bin -o boot.bin boot.asm

kernel_entry.o: kernel_entry.asm
	$(AS) -f elf32 -g -F dwarf kernel_entry.asm -o kernel_entry.o

%.o: %.c
	$(CC) $(CFLAGS) $< -o $@

kernel.bin: $(OBJECTS)
	$(LD) $(LDFLAGS) -o kernel.bin $(OBJECTS)

os-image: boot.bin kernel.bin
	cat boot.bin kernel.bin > os-image.bin

clean:
	rm -f *.o *.bin

.PHONY: all clean
