; Простое ядро (32-битный защищенный режим)
org 0x7E00
bits 32

start:
    ; Очистка экрана
    call clear_screen

    ; Вывод приветственного сообщения
    mov esi, msg_kernel
    mov edi, 0xB8000
    call print_string_pm

    ; Вывод меню
    call show_menu

main_loop:
    ; Ожидание ввода
    call read_key

    ; Проверка введенной клавиши
    cmp al, '1'
    je exit_os
    cmp al, '2'
    je show_about
    cmp al, '3'
    je clear_screen

    jmp main_loop

; Функции
clear_screen:
    mov edi, 0xB8000
    mov ecx, 80*25
    mov eax, 0x0F200F20
    rep stosd
    call show_menu
    ret

show_menu:
    mov esi, msg_menu
    mov edi, 0xB8000 + 160  ; Следующая строка
    call print_string_pm
    mov esi, msg_option1
    mov edi, 0xB8000 + 320  ; Через строку
    call print_string_pm
    mov esi, msg_option2
    mov edi, 0xB8000 + 480
    call print_string_pm
    mov esi, msg_option3
    mov edi, 0xB8000 + 640
    call print_string_pm
    ret

show_about:
    call clear_screen
    mov esi, msg_about
    mov edi, 0xB8000
    call print_string_pm
    ret

exit_os:
    ; Здесь можно добавить процедуру выключения
    cli
    hlt

read_key:
    ; Ожидание нажатия клавиши
.wait_key:
    in al, 0x64
    test al, 1
    jz .wait_key
    in al, 0x60
    ret

print_string_pm:
.loop:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0F
    mov [edi], ax
    add edi, 2
    jmp .loop
.done:
    ret

; Данные
msg_kernel db "LumiOS Started!", 0
msg_menu db "Select an option:", 0
msg_option1 db "1. Exit OS", 0
msg_option2 db "2. About System", 0
msg_option3 db "3. Clear Screen", 0
msg_about db "LumiOS v1.0", 13, 10, "A simple 32-bit operating system", 13, 10, "Press any key for menu", 0

; Заполнение до 10 секторов (для примера)
times 5120-($-$$) db 0
