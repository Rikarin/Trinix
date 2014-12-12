[bits 32]

%define INITIAL_KSTACK_SIZE	8
KERNEL_BASE	equ	0xFFFFFFFF80000000

[section .multiboot]
MbHdr:
	DD 0xE85250D6     ; Magic
	DD 0              ; Architecture
	DD HdrEnd - MbHdr ; Length
	DD -(0xE85250D6 + 0 + (HdrEnd - MbHdr)) ; Checksum
 
	; Sections override
	DW	2, 0
	DD	24

	[extern __load_addr]
	[extern __bss_start]
	[extern iKernelEnd]

	DD	MbHdr
	DD  __load_addr
	DD  __bss_start - KERNEL_BASE
	DD  iKernelEnd - KERNEL_BASE
 
	; Entry point override
	DW	3, 0
	DD	12
	DD	start - KERNEL_BASE
 
	; End Of Tags
	DW	0, 0
	DD	0
HdrEnd:

[extern start64]
[section .text]
[global start]
start:
	mov [iMultibootMagic - KERNEL_BASE], eax
	mov [iMultibootPtr - KERNEL_BASE], ebx

	; Check for Long Mode support
	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000001	; Compare the A-register with 0x80000001.
	jb .not64bitCapable
	mov eax, 0x80000001
	cpuid
	test edx, 1 << 29
	jz .not64bitCapable

	; Enable PGE (Page Global Enable)
	; + PAE (Physical Address Extension)
	; + PSE (Page Size Extensions)
	mov eax, cr4
	or eax, 0x80 | 0x20 | 0x10
	mov cr4, eax

	; Load PDP4
	mov eax, iInitialPML4 - KERNEL_BASE
	mov cr3, eax

	; Enable IA-32e mode
	; (Also enables SYSCALL and NX)
	mov ecx, 0xC0000080
	rdmsr
	or eax, (1 << 11) | (1 << 8) | (1 << 0) ; NXE, LME, SCE
	wrmsr

	; Enable paging
	mov eax, cr0
	or eax, 0x80010000	; PG & WP
	mov cr0, eax

	; Load GDT
	lgdt [iGDTPtr - KERNEL_BASE]
	jmp 0x08:start64 - KERNEL_BASE

.not64bitCapable:
	mov ah, 0x0F
	mov edi, 0xB8000
	mov esi, csNot64BitCapable - KERNEL_BASE

.loop:
	lodsb
	test al, al
	jz .hlt
	stosw
	jmp .loop
	
.hlt:
	cli
	hlt
	jmp .hlt

[section .data]
[global iGDT]
[global iGDTPtr]
iGDT:
	dd	0,0
	dd	0x00000000, 0x00209A00	; 0x08: 64-bit Code
	dd	0x00000000, 0x00009200	; 0x10: 64-bit Data
	dd	0x00000000, 0x0040FA00	; 0x18: 32-bit User Code
	dd	0x00000000, 0x0040F200	; 0x20: User Data
	dd	0x00000000, 0x0020FA00	; 0x28: 64-bit User Code
	dd	0x00000000, 0x0000F200	; 0x30: User Data (64 version)
	dd	0, 0x00008900, 0, 0	; 0x38+16*n: TSS 0
iGDTPtr:
	dw	$ - iGDT - 1
	dd	iGDT - KERNEL_BASE
	dd	0

[global iMultibootPtr]
[global iMultibootMagic]
iMultibootMagic:
	dd	0
iMultibootPtr:
	dd	0

[section .padata]
[global iInitialPML4]
iInitialPML4:	; Covers 256 TiB (Full 48-bit Virtual Address Space)
	dd	iInitialPDP - KERNEL_BASE + 3, 0	; Identity Map Low 4Mb
	times 0xA0 * 2 - 1 dq 0
	dd	iStackPDP - KERNEL_BASE + 3, 0
	times 512 - 4 - ($ - iInitialPML4) / 8 dq 0
	dd	iInitialPML4 - KERNEL_BASE + 3, 0	; Fractal Mapping
	dq	0
	dq	0
	dd	iHighPDP - KERNEL_BASE + 3, 0	; Map Low 4Mb to kernel base

iInitialPDP:	; Covers 512 GiB
	dd	iInitialPD - KERNEL_BASE + 3, 0
	times 511 dq 0

iStackPDP:
	dd	iStackPD - KERNEL_BASE + 3, 0
	times 511 dq 0

iHighPDP:	; Covers 512 GiB
	times 510 dq 0
	;dq	0 + 0x143	; 1 GiB Page from zero
	dd	iInitialPD - KERNEL_BASE + 3, 0
	dq	0

iInitialPD:	; Covers 1 GiB
;	dq	0 + 0x143	; 1 GiB Page from zero
	dd	iInitialPT1 - KERNEL_BASE + 3, 0
	dd	iInitialPT2 - KERNEL_BASE + 3, 0
	dd	iInitialPT3 - KERNEL_BASE + 3, 0
	times 509 dq 0

iStackPD:
	dd	iKStackPT - KERNEL_BASE + 3, 0
	times 511 dq 0

iKStackPT:	; Covers 2 MiB
	; Initial stack - 64KiB
	dq	0
	%assign i 0
	%rep INITIAL_KSTACK_SIZE - 1
	dd	iInitialKernelStack - KERNEL_BASE + i * 0x1000 + 0x103, 0
	%assign i i + 1
	%endrep
	times 512 - INITIAL_KSTACK_SIZE dq 0
iInitialPT1:	; 2 MiB
	%assign i 0
	%rep 512
	dq	i * 4096 + 0x103
	%assign i i + 1
	%endrep
iInitialPT2:	; 2 MiB
	%assign i 512
	%rep 512
	dq	i * 4096 + 0x103
	%assign i i + 1
	%endrep
iInitialPT3:	; 2 MiB
	%assign i 1024
	%rep 512
	dq	i * 4096 + 0x103
	%assign i i + 1
	%endrep

[section .padata]
[global iInitialKernelStack]
iInitialKernelStack:
	times 0x1000 * (INITIAL_KSTACK_SIZE - 1) db 0	; 8 Pages

[section .rodata]
csNot64BitCapable:
	db "CPU does not support long-mode, please use the x86 build", 0