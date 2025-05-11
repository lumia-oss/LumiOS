#ifndef IO_H
#define IO_H

// Константы для видеопамяти и цветов
#define VIDEO_MEMORY 0xB8000
#define COLS 80
#define ROWS 25
#define WHITE_ON_BLACK 0x0F

// Функции ввода-вывода
void clear_screen(void);
void print_string(const char* str);
void print_char(char c);
void print_at(const char* str, int row, int col);
char get_key(void);
void init_keyboard(void);

#endif
