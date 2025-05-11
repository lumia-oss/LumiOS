#!/bin/bash

# Проверка наличия инструментов
command -v nasm >/dev/null 2>&1 || { echo "Error: NASM is not installed. Please install it using:"; echo "sudo pacman -S nasm"; exit 1; }
command -v make >/dev/null 2>&1 || { echo "Error: Make is not installed. Please install it using:"; echo "sudo pacman -S make"; exit 1; }
command -v gcc >/dev/null 2>&1 || { echo "Error: GCC is not installed. Please install it using:"; echo "sudo pacman -S gcc"; exit 1; }
command -v qemu-system-i386 >/dev/null 2>&1 || { echo "Error: QEMU is not installed. Please install it using:"; echo "sudo pacman -S qemu-full"; exit 1; }

# Проверка multilib для 32-битной компиляции
if ! pacman -Q lib32-gcc-libs >/dev/null 2>&1; then
    echo "Installing 32-bit support..."
    echo "Please run:"
    echo "sudo pacman -S lib32-gcc-libs multilib-devel"
    exit 1
fi

# Очистка и сборка
make clean
make

# Запуск QEMU с отладочными опциями
qemu-system-i386 \
    -fda os-image.bin \
    -d cpu_reset,int,guest_errors \
    -no-reboot \
    -monitor stdio \
    -D qemu.log
