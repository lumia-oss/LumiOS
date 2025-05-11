#include "io.h"

static int cursor_x = 0;
static int cursor_y = 0;

// Port I/O functions
static inline unsigned char inb(unsigned short port) {
    unsigned char value;
    __asm__ volatile ("inb %1, %0" : "=a"(value) : "dN"(port));
    return value;
}

static inline void outb(unsigned short port, unsigned char value) {
    __asm__ volatile ("outb %0, %1" : : "a"(value), "dN"(port));
}

void clear_screen() {
    unsigned char* video_memory = (unsigned char*)VIDEO_MEMORY;
    for (int i = 0; i < COLS * ROWS * 2; i += 2) {
        video_memory[i] = ' ';
        video_memory[i + 1] = WHITE_ON_BLACK;
    }
    cursor_x = 0;
    cursor_y = 0;
}

void print_char(char c) {
    unsigned char* video_memory = (unsigned char*)VIDEO_MEMORY;

    if (c == '\n') {
        cursor_x = 0;
        cursor_y++;
        if (cursor_y >= ROWS) {
            cursor_y = 0;
            clear_screen();
        }
        return;
    }

    int offset = (cursor_y * COLS + cursor_x) * 2;
    video_memory[offset] = c;
    video_memory[offset + 1] = WHITE_ON_BLACK;

    cursor_x++;
    if (cursor_x >= COLS) {
        cursor_x = 0;
        cursor_y++;
        if (cursor_y >= ROWS) {
            cursor_y = 0;
            clear_screen();
        }
    }
}

void print_string(const char* str) {
    while (*str) {
        print_char(*str++);
    }
}

void print_at(const char* str, int row, int col) {
    cursor_x = col;
    cursor_y = row;
    print_string(str);
}

char get_key() {
    char c = 0;
    while ((c = inb(0x60)) & 0x80); // Wait for key release
    return c;
}

void init_keyboard() {
    // Basic keyboard initialization
    outb(0x64, 0xAE);    // Enable keyboard
    while (inb(0x64) & 2); // Wait for keyboard ready
}
