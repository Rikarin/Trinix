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




; externs given by the linker script
extern _edata
extern _end
extern _bss
extern _ebss

; extern to the load.s
extern start64
extern _stack

; define the starting point for this module
global start
global _start
start:
_start:
jmp $
; Stash values for multiboot we wont touch until 64 bit mode
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

; disable interrupts
cli

; enable SSE
;mov ecx, cr0
;btr ecx, 2
;bts ecx, 1
;mov cr0, ecx

;mov ecx, cr4
;bts ecx, 9
;bts ecx, 10
;mov cr4, ecx

; enable 64-bit page translation table entries
; by setting CR4.PAE = 1.
;
; Paging is not enabled until long mode.
mov eax, cr4
bts eax, 5
mov cr4, eax

; Create long mode page table and init CR3 to
; point to the base of the PML4 page table
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

jmp CS_KERNEL:(start64-KERNEL_VMA_BASE)

bits 64
code64Jump:
jmp (start64-KERNEL_VMA_BASE)




; Data Structures Follow
bits 32

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




; Temporary page tables

; These assume linking to 0xFFFF800000000000
align 4096
global pml4_base
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
; 15 tables are described here
; this maps 100 MB from address 0x0
; to an identity mapping
pml1_base:
%assign i 0
%rep 512*50
dq (i << 12) | 0x087
%assign i i+1
%endrep