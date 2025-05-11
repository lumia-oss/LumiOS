[bits 32]
[extern kernel_main]
global _start

_start:
    call kernel_main    ; Вызываем нашу main функцию из C
    jmp $              ; Зацикливаемся после завершения
