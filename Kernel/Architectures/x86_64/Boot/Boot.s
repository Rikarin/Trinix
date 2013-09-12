[section .text]
[bits 32]

; multiboot definitions
%define MULTIBOOT_HEADER_MAGIC 0x1BADB002
%define MULTIBOOT_HEADER_FLAGS 0x00010003

; where is the kernel?
%define KERNEL_VMA_BASE 0xFFFF800000000000
%define KERNEL_LMA_BASE 0x100000

; the gdt entry to use for the kernel
%define CS_KERNEL 0x10
%define CS_KERNEL32 0x08

; other definitions
%define STACK_SIZE 0x4000



extern _edata, _end, _bss, _ebss
extern start64, _stack
global start, _start

start:
_start:
	mov esi, ebx
	mov edi, eax
	jmp start32


; the multiboot header needs to be aligned at
; a 32 bit boundary
align 4

multiboot_header:
	dd MULTIBOOT_HEADER_MAGIC
	dd MULTIBOOT_HEADER_FLAGS
	dd -(MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS)
	dd multiboot_header
	dd _start
	dd (_bss-KERNEL_VMA_BASE)
	dd (_ebss-KERNEL_VMA_BASE)
	dd _start


; the 32 bit entry
global start32
start32:
	cli

	; enable 64-bit page translation table entries
	mov eax, cr4
	bts eax, 5
	mov cr4, eax

	; Create long mode page table and init CR3
	mov eax, pml4_base
	mov cr3, eax

	; Enable Long mode and SYSCALL / SYSRET instructions
	mov ecx, 0xC0000080
	rdmsr
	bts eax, 8
	bts eax, 0
	wrmsr

	; Load the 32 bit GDT
	lgdt [pGDT32]

	; Load the 32 bit IDT
	; lidt [pIDT32]

	; establish a stack for 32 bit code
	mov esp, (_stack-KERNEL_VMA_BASE) + STACK_SIZE

	; enable paging to activate long mode
	mov eax, cr0
	bts eax, 31
	mov cr0, eax

	jmp CS_KERNEL:to64


[bits 64]
to64:
	mov RAX, start64
	push RAX
	ret


; Data Structures Follow
[bits 32]

; 32 bit gdt
align 4096

global pGDT32
pGDT32:
dw GDT_END - GDT_TABLE - 1
dq GDT_TABLE - KERNEL_VMA_BASE

GDT_TABLE:
dq 0x0000000000000000	; Null Descriptor
dq 0x00cf9a000000ffff	; CS_KERNEL32
dq 0x00af9a000000ffff,0	; CS_KERNEL
dq 0x00af93000000ffff,0	; DS_KERNEL
dq 0x00affa000000ffff,0	; CS_USER
dq 0x00aff3000000ffff,0	; DS_USER
dq 0,0	;
dq 0,0	;
dq 0,0	;
dq 0,0	;

dq 0,0,0	; Three TLS descriptors
dq 0x0000f40000000000	;
GDT_END:



; These assume linking to 0xFFFF800000000000
global pml4_base

align 4096
pml4_base:
	dq (pml3_base + 0x7)
	times 255 dq 0
	dq (pml3_base + 0x7)
	times 253 dq 0
	dq (pml4_base + 0x7) ; paging trick
	dq 0

align 4096
pml3_base:
	dq (pml2_base + 0x7)
	times 511 dq 0

align 4096
pml2_base:
	%assign i 0
	%rep 50
	dq (pml1_base + i + 0x7)
	%assign i i+4096
	%endrep

times (512-50) dq 0

align 4096
pml1_base:
	%assign i 0
	%rep 512*50
	dq (i << 12) | 0x087
	%assign i i+1
	%endrep