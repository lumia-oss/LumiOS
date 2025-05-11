@echo offecho Building LumiOS...REM Проверяем наличие необходимых инструментовwhere make >nul 2>nulif %ERRORLEVEL% NEQ 0 (    echo Error: Make is not installed!    echo Please install Make from: https://gnuwin32.sourceforge.net/packages/make.htm    pause    exit /b 1)where i686-elf-gcc >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: i686-elf-gcc cross-compiler is not installed!
    echo Please install it from: https://wiki.osdev.org/GCC_Cross-Compiler
    pause
    exit /b 1
)

REM Очистка старых файлов
make clean

REM Сборка системы
make

REM Запуск в QEMU
qemu-system-i386 -fda os-image.bin

pause
