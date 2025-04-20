#include "keyboard.h"
#include "kernel.h"

#define PORT 0x60

unsigned char sc_ascii[] = {
    0, 27, '1','2','3','4','5','6','7','8','9','0','-','=', '\b',
    '\t', 'q','w','e','r','t','y','u','i','o','p','[',']','\n', 0,
    'a','s','d','f','g','h','j','k','l',';','\'','`', 0, '\\',
    'z','x','c','v','b','n','m',',','.','/', 0,'*', 0,' '
};

static inline unsigned char inb(unsigned short port) {
    unsigned char ret;
    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

static inline void outb(unsigned short port, unsigned char val) {
    __asm__ volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

void keyboard_callback() {
    unsigned char sc = inb(PORT);
    if (sc < sizeof(sc_ascii)) {
        char c = sc_ascii[sc];
        if (c) print_char(c);
    }

    outb(0x20, 0x20); // EOI
}

void init_keyboard() { }
