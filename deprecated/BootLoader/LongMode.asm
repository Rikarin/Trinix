[bits 32]

CheckCPU:
    pushfd

    pop eax
    mov ecx, eax
    xor eax, 0x200000
    push eax
    popfd

    pushfd
    pop eax
    xor eax, ecx
    shr eax, 21
    and eax, 1
    push ecx
    popfd

    test eax, eax
    jz .NoLongMode

    mov eax, 0x80000000
    cpuid

    cmp eax, 0x80000001
    jb .NoLongMode

    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz .NoLongMode

    ret

    .NoLongMode:
        stc
        ret

SwitchToLongMode:
    mov edi, 0x20000
    mov cr3, edi

    ;Page map
    mov DWORD [0x20000], 0x21003 ;PDPT
    mov DWORD [0x21000], 0x22003 ;PD

    mov DWORD [0x22000], 0x23003 ;PTs
	mov DWORD [0x22008], 0x24003
	mov DWORD [0x22010], 0x25003
	mov DWORD [0x22018], 0x26003
	mov DWORD [0x22020], 0x27003
	mov DWORD [0x22028], 0x28003

	mov eax, 6
    mov ebx, 0x3
	mov edi, 0x23000
	
	.lp:
		mov ecx, 512
		.SetEntry:
			mov DWORD [edi], ebx
			add ebx, 0x1000
			add edi, 8
			loop .SetEntry
		
		dec eax
		jnz .lp


    ;Enable PAE paging
    mov eax, cr4                 ; Set the A-register to control register 4.
    or eax, 1 << 5               ; Set the PAE-bit, which is the 6th bit (bit 5).
    mov cr4, eax                 ; Set control register 4 to the A-register.

    ;Switch to Long mode
    mov ecx, 0xC0000080          ; Set the C-register to 0xC0000080, which is the EFER MSR.
    rdmsr                        ; Read from the model-specific register.
    or eax, 1 << 8               ; Set the LM-bit which is the 9th bit (bit 8).
    wrmsr

    ;Enable paging
    mov eax, cr0                 ; Set the A-register to control register 0.
    or eax, 1 << 31              ; Set the PG-bit, which is the 32nd bit (bit 31).
    mov cr0, eax                 ; Set control register 0 to the A-register.

    lgdt [GDT.Pointer]                ; Load GDT.Pointer defined below.
    jmp 0x08:LongMode             ; Load CS with 64 bit segment and flush the instruction cache

; Global Descriptor Table
GDT:
    .Null:
        dq 0
    .Code:
        dw 0                         ; Limit (low).
        dw 0                         ; Base (low).
        db 0                         ; Base (middle)
        db 0x9A                      ; Access.
        db 0x20                      ; Granularity.
        db 0                         ; Base (high).
    .Data:
        dw 0                         ; Limit (low).
        dw 0                         ; Base (low).
        db 0                         ; Base (middle)
        db 0x92                      ; Access.
        db 0x20                      ; Granularity.
        db 0                         ; Base (high).

    ALIGN 4
        dw 0                              ; Padding to make the "address of the GDT" field aligned on a 4-byte boundary
        .end:

    .Pointer:
        dw GDT.end - GDT - 1                    ; 16-bit Size (Limit) of GDT.
        dq GDT                            ; 32-bit Base Address of GDT. (CPU will zero extend to 64-bit)
 
 
[bits 64]
LongMode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ;mov rsp, 0xFFFFFFFFC0015000
    mov rsp, 0x19000
    mov rbp, rsp

    ;push qword vbe_controller_info
    ;mov rax, video_mode_description
    ;or rax, 0xFFFFFFFFC0000000
    ;push rax

    mov rdi, rsp
    ;jmp 0xFFFFFFFFC0100000
    jmp 0x100000
