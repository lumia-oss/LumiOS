CC = gcc
AS = nasm
LD = ld

# Флаги для компиляции без стандартной библиотеки
CFLAGS = -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector \
         -nostartfiles -nodefaultlibs -Wall -Wextra -Werror -c \
         -fno-exceptions -ffreestanding -O2

# Флаги линковки
LDFLAGS = -T linker.ld -melf_i386 -nostdlib

OBJECTS = kernel_entry.o kernel.o io.o

all: os-image

boot.bin: boot.asm
	$(AS) -f bin boot.asm -o boot.bin

kernel_entry.o: kernel_entry.asm
	$(AS) -f elf32 kernel_entry.asm -o kernel_entry.o

%.o: %.c
	$(CC) $(CFLAGS) $< -o $@

kernel.bin: $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o kernel.bin

os-image: boot.bin kernel.bin
	cat boot.bin kernel.bin > os-image.bin

clean:
	rm -f *.o *.bin

.PHONY: all clean
