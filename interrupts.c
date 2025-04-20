#include <stdint.h>
#include "interrupts.h"

#define IDT_SIZE 256

struct IDTEntry {
    uint16_t offset_low;
    uint16_t selector;
    uint8_t zero;
    uint8_t type_attr;
    uint16_t offset_high;
} __attribute__((packed));

struct IDTPointer {
    uint16_t limit;
    uint32_t base;
} __attribute__((packed));

extern void isr_keyboard();
struct IDTEntry idt[IDT_SIZE];
struct IDTPointer idtp;

static inline void outb(uint16_t port, uint8_t val) {
    __asm__ volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

static void set_idt_gate(int n, uint32_t handler) {
    idt[n].offset_low = handler & 0xFFFF;
    idt[n].selector = 0x08;
    idt[n].zero = 0;
    idt[n].type_attr = 0x8E;
    idt[n].offset_high = (handler >> 16) & 0xFFFF;
}

void init_idt() {
    idtp.limit = sizeof(idt) - 1;
    idtp.base = (uint32_t)&idt;

    for (int i = 0; i < IDT_SIZE; i++)
        set_idt_gate(i, 0);

    set_idt_gate(0x21, (uint32_t)isr_keyboard);

    __asm__ volatile("lidtl (%0)" :: "r"(&idtp));

    // Remap PIC
    outb(0x20, 0x11);
    outb(0xA0, 0x11);
    outb(0x21, 0x20);
    outb(0xA1, 0x28);
    outb(0x21, 0x04);
    outb(0xA1, 0x02);
    outb(0x21, 0x01);
    outb(0xA1, 0x01);
    outb(0x21, 0x0);
    outb(0xA1, 0x0);

    __asm__ volatile("sti");
}
