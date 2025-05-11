#include "io.h"

void show_menu() {
    clear_screen();
    print_string("=== LumiOS Menu ===\n\n");
    print_string("1. Clear Screen\n");
    print_string("2. System Info\n");
    print_string("3. Exit\n\n");
    print_string("Select an option: ");
}

void show_system_info() {
    clear_screen();
    print_string("=== System Information ===\n\n");
    print_string("LumiOS Version 1.0\n");
    print_string("Simple 32-bit Operating System\n");
    print_string("Written in C\n\n");
    print_string("Press any key to return to menu...\n");
    get_key();
}

void kernel_main() {
    init_keyboard();
    clear_screen();

    while(1) {
        show_menu();
        char choice = get_key();

        switch(choice) {
            case '1':
                clear_screen();
                break;
            case '2':
                show_system_info();
                break;
            case '3':
                clear_screen();
                print_string("Shutting down...\n");
                return;
        }
    }
}
