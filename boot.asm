[BITS 16]
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Load 15 sectors (kernel) from disk to 0x1000
    mov bx, 0x1000         ; ES:BX = 0:1000
    mov ah, 0x02           ; BIOS read sector function
    mov al, 15             ; Read 15 sectors
    mov ch, 0              ; Cylinder
    mov cl, 2              ; Sector (start at 2, because 1 is boot)
    mov dh, 0              ; Head
    mov dl, 0x80           ; Drive (first HDD)
    int 0x13
    jc disk_error

    ; Set up a basic GDT for protected mode
    cli
    lgdt [gdt_descriptor]

    ; Set PE (Protection Enable) bit in CR0
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Far jump to flush prefetch queue and enter protected mode
    jmp CODE_SEG:init_pm

disk_error:
    hlt
    jmp disk_error

; -------------------------
; 32-bit protected mode
; -------------------------
[BITS 32]
init_pm:
    ; Set up segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000         ; Give stack some space

    ; Jump to kernel
    jmp 0x0000:0x1000

; -------------------------
; GDT
; -------------------------
gdt_start:
    ; null descriptor
    dd 0
    dd 0

    ; code segment: base=0, limit=4GB, type=code
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

    ; data segment: base=0, limit=4GB, type=data
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ 0x08
DATA_SEG equ 0x10

times 510 - ($ - $$) db 0
dw 0xAA55
