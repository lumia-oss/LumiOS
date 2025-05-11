[bits 16]
[org 0x7c00]

; Константы
KERNEL_OFFSET equ 0x1000
VIDEO_MEMORY equ 0xb8000

start:
    ; Настройка сегментных регистров
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    ; Сохраняем номер загрузочного диска
    mov [boot_drive], dl

    ; Сообщение о начале загрузки
    mov si, msg_start
    call print_string

    ; Загрузка ядра с диска
    mov si, msg_load_kernel
    call print_string

    mov bx, KERNEL_OFFSET
    mov dh, 20            ; Увеличиваем количество секторов
    mov dl, [boot_drive]
    call load_disk

    mov si, msg_kernel_ok
    call print_string

    ; Подготовка к переключению в защищенный режим
    mov si, msg_prep_pm
    call print_string

    cli
    lgdt [gdt_descriptor]

    ; Включаем A20 линию
    in al, 0x92
    or al, 2
    out 0x92, al

    ; Переключение в защищенный режим
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    ; Прыжок для очистки конвейера
    jmp CODE_SEG:init_pm

; Функции реального режима
print_string:
    mov ah, 0x0e
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

print_hex:
    pusha
    mov cx, 4   ; 4 hex digits
.loop:
    dec cx
    mov ax, dx
    shr dx, 4
    and ax, 0xf
    mov bx, hex_chars
    add bx, ax
    mov al, [bx]
    mov bx, cx
    mov [hex_out + bx + 2], al
    cmp cx, 0
    jne .loop
    mov si, hex_out
    call print_string
    popa
    ret

load_disk:
    push dx
    mov ah, 0x02    ; BIOS read function
    mov al, dh      ; Number of sectors
    mov ch, 0x00    ; Cylinder 0
    mov cl, 0x02    ; Start from sector 2
    mov dh, 0x00    ; Head 0
    int 0x13
    jc disk_error
    pop dx
    cmp dh, al
    jne disk_error
    ret

disk_error:
    mov si, msg_disk_error
    call print_string
    jmp $

[bits 32]
init_pm:
    ; Настройка сегментных регистров для защищенного режима
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Настройка стека
    mov ebp, 0x90000
    mov esp, ebp

    ; Вызов ядра
    call KERNEL_OFFSET

    ; Если мы сюда попали, значит что-то пошло не так
    mov dword [VIDEO_MEMORY], 0x4F524F45 ; 'ERR' в красном цвете
    jmp $

; Данные
msg_start db "Starting bootloader...", 0x0D, 0x0A, 0
msg_load_kernel db "Loading kernel into memory...", 0x0D, 0x0A, 0
msg_kernel_ok db "Kernel loaded successfully!", 0x0D, 0x0A, 0
msg_prep_pm db "Preparing to switch to protected mode...", 0x0D, 0x0A, 0
msg_disk_error db "Error loading kernel from disk!", 0x0D, 0x0A, 0
hex_chars db "0123456789ABCDEF"
hex_out db "0x0000", 0x0D, 0x0A, 0
boot_drive db 0

; GDT
gdt_start:
    dd 0x0, 0x0    ; Нулевой дескриптор

gdt_code:          ; Сегмент кода
    dw 0xffff      ; Limit (0-15)
    dw 0x0         ; Base (0-15)
    db 0x0         ; Base (16-23)
    db 10011010b   ; Access
    db 11001111b   ; Flags + Limit (16-19)
    db 0x0         ; Base (24-31)

gdt_data:          ; Сегмент данных
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

; Заполнение и сигнатура
times 510 - ($ - $$) db 0
dw 0xaa55
