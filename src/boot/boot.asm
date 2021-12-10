ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; bios parameter block
; _start is used to short jmp to start and we fill 33 bytes in between with 0.
; this is to avoid bios to write data to our code.
_start:
    jmp short start
    nop

times 33 db 0

start:
    jmp 0:main

main:
    cli ; Clear Interupts
    ; Manually setup segment registers so they won't cause issues
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00  ; Stack moves downwards so setting stack pointer to 0x7c00
    sti ; Start Interupts

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or  eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32

; GDT
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

gdt_code:        ; CS SHOULD POINT TO THIS
    dw 0xffff    ; Segment limit first 0-15 bits
    dw 0         ; Base first 0-15 bits
    db 0         ; Base 16-23 bits
    db 0x9a      ; Access byte
    db 11001111b ; High 4 bit flags and the low 4 bit flags
    db 0         ; Base 24-31 bits

gdt_data:      ; DS, SS, ES, FS, GS
    dw 0xffff ; Segment limit first 0-15 bits
    dw 0      ; Base first 0-15 bits
    db 0      ; Base 16-23 bits
    db 0x92   ; Access byte
    db 11001111b ; High 4 bit flags and the low 4 bit flags
    db 0        ; Base 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start-1
    dd gdt_start
 
[BITS 32]
load32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp
    jmp $

; Fill values with 0 to make 512 byte binary 
; $ -> Current address $$ -> Start address
times 510 - ($ - $$) db 0

; Write 2 byte (Word) 0x55AA at end of bin
dw 0xAA55