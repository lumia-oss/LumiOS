@echo off
echo Building LumiOS...

REM Проверяем наличие необходимых инструментов
where gcc >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: GCC is not installed!
    echo Please install MinGW-w64 from: https://winlibs.com/
    echo Make sure to choose the version with i686 (32-bit) support
    pause
    exit /b 1
)

where nasm >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: NASM is not installed!
    echo Please install NASM from: https://www.nasm.us/
    pause
    exit /b 1
)

where make >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: Make is not installed!
    echo Please install Make from MinGW or install complete MinGW-w64
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
