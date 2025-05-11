[bits 32]
[extern kernel_main]    ; Объявляем внешнюю функцию kernel_main
global _start

section .text
_start:
    ; Настраиваем сегменты данных
    mov ax, 0x10    ; Смещение сегмента данных в GDT
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Настраиваем стек
    mov ebp, 0x90000
    mov esp, ebp

    ; Вызываем основную функцию ядра
    call kernel_main

    ; Если kernel_main вернулся, входим в бесконечный цикл
    cli             ; Отключаем прерывания
.halt:
    hlt            ; Останавливаем процессор
    jmp .halt      ; Бесконечный цикл
