#!/bin/bash

# Проверка наличия необходимых инструментов
command -v nasm >/dev/null 2>&1 || { echo "Error: NASM is not installed. Please install it using:"; echo "sudo apt-get install nasm"; exit 1; }
command -v make >/dev/null 2>&1 || { echo "Error: Make is not installed. Please install it using:"; echo "sudo apt-get install make"; exit 1; }
command -v gcc >/dev/null 2>&1 || { echo "Error: GCC is not installed. Please install it using:"; echo "sudo apt-get install gcc"; exit 1; }
command -v qemu-system-i386 >/dev/null 2>&1 || { echo "Error: QEMU is not installed. Please install it using:"; echo "sudo apt-get install qemu-system-x86"; exit 1; }

# Проверка наличия 32-битных библиотек
if ! dpkg -l | grep -q "gcc-multilib"; then
    echo "Installing 32-bit support..."
    sudo apt-get install gcc-multilib
fi

# Очистка старых файлов
make clean

# Сборка системы
make

# Запуск в QEMU
qemu-system-i386 -fda os-image.bin
