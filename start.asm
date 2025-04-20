[BITS 32]
extern _start
extern keyboard_callback

global loader_entry
global isr_keyboard

isr_keyboard:
    pusha
    call keyboard_callback
    popa
    iretd

loader_entry:
    call _start
.hang:
    hlt
    jmp .hang
