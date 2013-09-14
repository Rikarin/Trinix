[section .text]
[bits 32]

extern _edata, _ebss
extern start64, _stack
global _start

_start:
	mov esi, ebx
	mov edi, eax
	jmp start32


; the multiboot header needs to be aligned at
; a 32 bit boundary
align 4

MbHdr:
	; Magic
	DD	0xE85250D6
	; Architecture
	DD	0
	; Length
	DD	HdrEnd - MbHdr
	; Checksum
	DD	-(0xE85250D6 + 0 + (HdrEnd - MbHdr))
 
	;
	; Tags
	;
 
	; Sections override
	DW	2, 0
	DD	24
	DD	MbHdr
	DD  _start
	DD  _edata
	DD  _ebss
 
	; Entry point override
	DW	3, 0
	DD	12
	DD	_start
 
	; End Of Tags
	DW	0, 0
	DD	8
HdrEnd:



; the 32 bit entry
global start32
start32:
	cli

	; enable 64-bit page translation table entries
	mov eax, cr4
	or eax, 1 << 5
	mov cr4, eax

	; Create long mode page table and init CR3
	mov eax, pml4_base
	mov cr3, eax

	; Enable Long mode and SYSCALL / SYSRET instructions
	mov ecx, 0xC0000080
	rdmsr
	or eax, 1 << 8
	wrmsr

	; establish a stack for 32 bit code
	mov esp, _stack + 0x4000

	; enable paging to activate long mode
	mov eax, cr0
	or eax, 1 << 31
	mov cr0, eax

	; Load the 32 bit GDT
	lgdt [pGDT32]

	jmp 0x10:start64


; Data Structures Follow
[bits 32]

; 32 bit gdt
align 4096

pGDT32:
dw GDT_END - GDT_TABLE - 1
dq GDT_TABLE

GDT_TABLE:
dq 0x0000000000000000	; Null Descriptor
dq 0x00cf9a000000ffff	; CS_KERNEL32
dq 0x00af9a000000ffff,0	; CS_KERNEL
dq 0x00af93000000ffff,0	; DS_KERNEL
dq 0x00affa000000ffff,0	; CS_USER
dq 0x00aff3000000ffff,0	; DS_USER
GDT_END:



global pml4_base

align 4096
pml4_base:
	dq (pml3_base + 0x7)
	times 511 dq 0

align 4096
pml3_base:
	dq (pml2_base + 0x7)
	times 511 dq 0

align 4096
pml2_base:
	%assign i 0
	%rep 0x60
	dq (pml1_base + i + 0x7)
	%assign i i+4096
	%endrep

	%assign i 0
	%rep 0x60
	dq (pml1_base + i + 0x7)
	%assign i i+4096
	%endrep


;0x60 - 96
times (512-0x120) dq 0

align 4096
pml1_base:
	%assign i 0
	%rep 512*0x60
	dq (i << 12) | 0x087
	%assign i i+1
	%endrep