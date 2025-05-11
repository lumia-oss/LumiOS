[bits 16]
[org 0x7c00]

KERNEL_OFFSET equ 0x1000    ; Соответствует линкер скрипту

start:
    ; Настройка сегментных регистров
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    ; Сохраняем номер загрузочного диска
    mov [boot_drive], dl

    ; Очистка экрана
    mov ax, 0x0003
    int 0x10

    ; Сообщение о загрузке
    mov si, msg_loading
    call print_string

    ; Загрузка ядра с диска
    mov bx, KERNEL_OFFSET  ; Загружаем ядро по адресу из линкер скрипта
    mov dh, 15            ; Количество секторов (увеличено для безопасности)
    mov dl, [boot_drive]
    call load_disk

    ; Переключение в защищенный режим
    cli                     ; Отключаем прерывания
    lgdt [gdt_descriptor]   ; Загружаем GDT

    mov eax, cr0
    or eax, 0x1            ; Включаем защищенный режим
    mov cr0, eax

    jmp CODE_SEG:init_pm   ; Дальний прыжок для очистки конвейера

disk_error:
    mov si, disk_error_msg
    call print_string
    jmp $

print_string:
    pusha
    mov ah, 0x0e
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

load_disk:
    pusha
    push dx

    mov ah, 0x02    ; Чтение секторов
    mov al, dh      ; Количество секторов
    mov ch, 0       ; Цилиндр 0
    mov dh, 0       ; Головка 0
    mov cl, 2       ; Начиная со второго сектора

    int 0x13
    jc disk_error   ; Проверка на ошибку

    pop dx
    cmp dh, al      ; Сравниваем сколько секторов реально прочитано
    jne disk_error

    popa
    ret

[bits 32]
init_pm:
    mov ax, DATA_SEG    ; Теперь в защищенном режиме
    mov ds, ax          ; Обновляем все сегментные регистры
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000    ; Обновляем стек
    mov esp, ebp

    jmp CODE_SEG:KERNEL_OFFSET    ; Прыжок на ядро с правильным сегментом

; GDT
gdt_start:
    dq 0x0        ; Нулевой дескриптор

gdt_code:         ; Сегмент кода
    dw 0xffff     ; Limit (0-15)
    dw 0x0        ; Base (0-15)
    db 0x0        ; Base (16-23)
    db 10011010b  ; Flags (Present, Ring 0, Code)
    db 11001111b  ; Flags + Limit (16-19)
    db 0x0        ; Base (24-31)

gdt_data:         ; Сегмент данных
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; Данные
msg_loading: db "Loading kernel...", 0x0D, 0x0A, 0
disk_error_msg: db "Disk read error!", 0
boot_drive: db 0

times 510-($-$$) db 0
dw 0xaa55
