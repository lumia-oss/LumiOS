; Простой загрузчик (16-битный реальный режим)
org 0x7C00
bits 16

start:
    ; Настройка сегментных регистров
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Очистка экрана
    mov ax, 0x0003
    int 0x10

    ; Сообщение о загрузке
    mov si, msg_loading
    call print_string

    ; Загрузка ядра с диска
    mov ah, 0x02        ; Функция чтения диска
    mov al, 10          ; Количество секторов для чтения (ядро)
    mov ch, 0           ; Цилиндр
    mov cl, 2           ; Сектор (начинается с 1)
    mov dh, 0           ; Головка
    mov bx, 0x7E00      ; Адрес загрузки (сразу после загрузчика)
    int 0x13
    jc disk_error       ; Если ошибка

    ; Переход в защищенный режим
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:init_pm

disk_error:
    mov si, msg_disk_error
    call print_string
    jmp $

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

; Данные
msg_loading db "Loading kernel...", 0x0D, 0x0A, 0
msg_disk_error db "Disk error!", 0x0D, 0x0A, 0

; GDT для защищенного режима
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0
gdt_code:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0
gdt_data:
    dw 0xFFFF
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

; Переход в 32-битный режим
bits 32
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x90000
    mov esp, ebp

    ; Переход к ядру
    jmp 0x7E00

; Заполнение до 512 байт и сигнатура загрузочного сектора
times 510-($-$$) db 0
dw 0xAA55
