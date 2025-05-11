[bits 32]
[extern kernel_main]
global _start

section .text
_start:
    ; Устанавливаем стек
    mov esp, stack_space

    ; Проверяем, что мы успешно загрузились, выводя символ
    mov dword [0xb8000], 0x2F4B2F4F  ; OK в зеленом цвете

    ; Вызываем основную функцию ядра
    call kernel_main

    ; Если kernel_main вернулся, входим в бесконечный цикл
    jmp $

section .bss
    resb 8192        ; 8KB для стека
stack_space:
