ORG 0
BITS 16

; bios parameter block
; _start is used to short jmp to start and we fill 33 bytes in between with 0.
; this is to avoid bios to write data to our code.
_start:
    jmp short start
    nop

times 33 db 0

start:
    jmp 0x7c0:main

main:
    cli ; Clear Interupts
    ; Manually setup segment registers so they won't cause issues
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00  ; Stack moves downwards so setting stack pointer to 0x7c00
    sti ; Start Interupts

    ; Video-Teletype Output Interupt to print message on screen
    mov ah, 0eh
    mov si, message 
    mov bl, 0
    call print
    jmp $

print:
    lodsb
    int 0x10
    cmp al, 0
    je .return
    jmp print

.return:
    ret

message: db 'Hello World!..' ,0

; Fill values with 0 to make 512 byte binary 
; $ -> Current address $$ -> Start address
times 510 - ($ - $$) db 0

; Write 2 byte (Word) 0x55AA at end of bin
dw 0xAA55