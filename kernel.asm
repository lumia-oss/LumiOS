; Простое ядро (32-битный защищенный режим)
org 0x7E00
bits 32

start:
    ; Очистка экрана
    mov edi, 0xB8000
    mov ecx, 80*25
    mov eax, 0x0F200F20
    rep stosd

    ; Вывод приветственного сообщения
    mov esi, msg_kernel
    mov edi, 0xB8000
    call print_string_pm

    ; Бесконечный цикл
    jmp $

print_string_pm:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0F
    mov [edi], ax
    add edi, 2
    jmp print_string_pm
.done:
    ret

; Данные
msg_kernel db "LumiOS Started!", 0

; Заполнение до 10 секторов (для примера)
times 5120-($-$$) db 0
