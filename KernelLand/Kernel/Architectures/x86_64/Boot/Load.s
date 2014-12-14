[bits 64]

%define INITIAL_KSTACK_SIZE	8
KERNEL_BASE	equ	0xFFFFFFFF80000000

[extern ArchMain]

[extern iMultibootPtr]
[extern iMultibootMagic]

[section .text]
[global start64]
start64:
	; Load Registers
	mov ax, 0x10
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	; Go to high memory
	mov rax, start64.himem
	jmp rax

.himem:
	xor rax, rax
	mov dr0, rax ; Set CPU0
	
	; Set kernel stack
	mov rsp, 0xFFFFFFFF80010000 + INITIAL_KSTACK_SIZE * 0x1000

	; Call main
	mov edi, [iMultibootMagic - KERNEL_BASE]
	mov esi, [iMultibootPtr - KERNEL_BASE]
	call ArchMain
	
	cli
.hlt:
	hlt
	jmp .hlt