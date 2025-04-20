#include "kernel.h"
#include "interrupts.h"
#include "keyboard.h"

char* video = (char*) 0xB8000;
int cursor = 0;

void print(const char* str) {
    while (*str) {
        video[cursor++] = *str++;
        video[cursor++] = 0x0F;
    }
}

void print_char(char c) {
    video[cursor++] = c;
    video[cursor++] = 0x0F;
}

void _start() {
    print("Type something:\n");

    init_idt();
    init_keyboard();

    while (1) {
        __asm__ __volatile__("hlt");
    }
}
