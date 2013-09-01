[bits 16]
[org 0x7c00]

; Save boot drive
mov [drive], dl

; Reset drive
reset:
    mov ah, 0
    int 0x13
    jc reset

; Enable A20 gate
call _enable_a20

; Setup GDT table
call _install_gdt

; Load second part of bootloader
mov ah, 0x42
mov dl, [drive]
mov si, VBEPacket
int 0x13

; Load memory map
mov di, 0x7000
call _get_memory_map

;call setup_video_mode

; Load Kernel from drive to memory and move to 0x10000
loadKernel:
    mov ax, [count]
    or ax, ax
    jz Stage2
    dec ax
    mov [count], ax

    mov ah, 0x42
    mov dl, [drive]
    mov si, Packet
    int 0x13

    mov eax, cr0
    mov edx, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:.copyKernel

    [bits 32]
    .copyKernel:
        cli
        mov ax, 0x10
        mov ds, ax
        mov ss, ax
        mov es, ax

        mov ecx, 16256
        mov esi, 0x10000
        mov edi, [address]
        rep movsd

        mov [address], edi
        add DWORD [Packet.buffer], 0x7F

        jmp 0x18:.pmode16

    [bits 16]
    .pmode16:
        mov ax, 0x20
        mov ss, ax
        mov cr0, edx
        jmp 0x0:.rmode

    .rmode:
        mov ax, 0
        mov ds, ax
        mov ss, ax
        mov es, ax
        sti
        jmp loadKernel

; If Kernel has been loaded run stage 2
Stage2:
    ;Enable protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:Stage3

drive:      db 0
Packet:
    .size   db 0x10       ; Packet size
    .zero   db 0          ; Reserved
    .number dw 0x7F       ; Number of block to load
    .dest   dd 0x10000000 ; Destination address
    .buffer dq 0x4        ; Position on disk
VBEPacket:
    .size   db 0x10       ; Packet size
    .zero   db 0          ; Reserved
    .number dw 0x3        ; Number of block to load
    .dest   dd 0x7E00     ; Destination address
    .buffer dq 0x1        ; Position on disk
count:      dw 150         ; count * 65KB
address:    dd 0x100000   ; Kernel address
MemRegCount: dw 0


%include "A20.asm"
%include "GDT.asm"
%include "MemoryMap.asm"

times (510-($-$$)) db 0
DW 0xAA55
;=================================== PART 2 ====================================
%include "VESA.asm"

[bits 32]

Stage3:
    cli
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov es, ax

    call CheckCPU
    jc halt
    jmp SwitchToLongMode

halt:
    jmp halt

IDT:
    .Length dw 0
    .Base   dd 0

%include "LongMode.asm"

times (2048-($-$$)) db 0
