;;;
 ; Copyright (c) 2015 Trinix Foundation. All rights reserved.
 ; 
 ; This file is part of Trinix Operating System and is released under Trinix 
 ; Public Source Licence Version 1.0 (the 'Licence'). You may not use this file
 ; except in compliance with the License. The rights granted to you under the
 ; License may not be used to create, or enable the creation or redistribution
 ; of, unlawful or unlicensed copies of an Trinix operating system, or to
 ; circumvent, violate, or enable the circumvention or violation of, any terms
 ; of an Trinix operating system software license agreement.
 ; 
 ; You may obtain a copy of the License at
 ; https://github.com/TrinixFoundation/ and read it before using this file.
 ; 
 ; The Original Code and all software distributed under the License are
 ; distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 ; KIND, either express or implied. See the License for the specific language
 ; governing permissions and limitations under the License.
 ; 
 ; Contributors:
 ;      Matsumoto Satoshi <satoshi@gshost.eu>
 ;;

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
	[extern __linker_kernel_end]

	DD	MbHdr
	DD  __load_addr
	DD  __bss_start - KERNEL_BASE
	DD  __linker_kernel_end - KERNEL_BASE
 
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
	mov [__multiboot_magic - KERNEL_BASE], eax
	mov [__multiboot_ptr - KERNEL_BASE], ebx

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
	mov eax, __initial_pml4 - KERNEL_BASE
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
	lgdt [__boot_gdt_ptr - KERNEL_BASE]
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
[global __boot_gdt]
[global __boot_gdt_ptr]
__boot_gdt:
	dd	0,0
	dd	0x00000000, 0x00209A00	; 0x08: 64-bit Code
	dd	0x00000000, 0x00009200	; 0x10: 64-bit Data
	dd	0x00000000, 0x0040FA00	; 0x18: 32-bit User Code
	dd	0x00000000, 0x0040F200	; 0x20: User Data
	dd	0x00000000, 0x0020FA00	; 0x28: 64-bit User Code
	dd	0x00000000, 0x0000F200	; 0x30: User Data (64 version)
	dd	0, 0x00008900, 0, 0	; 0x38+16*n: TSS 0
__boot_gdt_ptr:
	dw	$ - __boot_gdt - 1
	dd	__boot_gdt - KERNEL_BASE
	dd	0

[global __multiboot_ptr]
[global __multiboot_magic]
__multiboot_magic:
	dd	0
__multiboot_ptr:
	dd	0

[section .padata]
[global __initial_pml4]
__initial_pml4:	; Covers 256 TiB (Full 48-bit Virtual Address Space)
	dd	__initial_pdp - KERNEL_BASE + 3, 0	; Identity Map Low 4Mb
	times 0xA0 * 2 - 1 dq 0
	dd	__initial_stack_pdp - KERNEL_BASE + 3, 0
	times 512 - 4 - ($ - __initial_pml4) / 8 dq 0
	dd	__initial_pml4 - KERNEL_BASE + 3, 0	; Fractal Mapping
	dq	0
	dq	0
	dd	__initial_high_pdp - KERNEL_BASE + 3, 0	; Map Low 4Mb to kernel base

__initial_pdp:	; Covers 512 GiB
	dd	__initial_pd - KERNEL_BASE + 3, 0
	times 511 dq 0

__initial_stack_pdp:
	dd	__initial_stack_pd - KERNEL_BASE + 3, 0
	times 511 dq 0

__initial_high_pdp:	; Covers 512 GiB
	times 510 dq 0
	;dq	0 + 0x143	; 1 GiB Page from zero
	dd	__initial_pd - KERNEL_BASE + 3, 0
	dq	0

__initial_pd:	; Covers 1 GiB
;	dq	0 + 0x143	; 1 GiB Page from zero
	dd	__initial_pt_1 - KERNEL_BASE + 3, 0
	dd	__initial_pt_2 - KERNEL_BASE + 3, 0
	dd	__initial_pt_3 - KERNEL_BASE + 3, 0
    dd  __initial_pt_4 - KERNEL_BASE + 3, 0
    dd  __initial_pt_5 - KERNEL_BASE + 3, 0
    dd  __initial_pt_6 - KERNEL_BASE + 3, 0
	times 506 dq 0

__initial_stack_pd:
	dd	_initial_stack_pt - KERNEL_BASE + 3, 0
	times 511 dq 0

_initial_stack_pt:	; Covers 2 MiB
	; Initial stack - 64KiB
	dq	0
	%assign i 0
	%rep INITIAL_KSTACK_SIZE - 1
	dd	__initial_kernel_stack - KERNEL_BASE + i * 0x1000 + 0x103, 0
	%assign i i + 1
	%endrep
	times 512 - INITIAL_KSTACK_SIZE dq 0
__initial_pt_1:	; 2 MiB
	%assign i 0
	%rep 512
	dq	i * 4096 + 0x103
	%assign i i + 1
	%endrep
__initial_pt_2:	; 2 MiB
	%assign i 512
	%rep 512
	dq	i * 4096 + 0x103
	%assign i i + 1
	%endrep
__initial_pt_3:	; 2 MiB
	%assign i 1024
	%rep 512
	dq	i * 4096 + 0x103
	%assign i i + 1
	%endrep
__initial_pt_4:    ; 2 MiB
    %assign i 1536
    %rep 512
    dq  i * 4096 + 0x103
    %assign i i + 1
    %endrep
__initial_pt_5:    ; 2 MiB
    %assign i 2048
    %rep 512
    dq  i * 4096 + 0x103
    %assign i i + 1
    %endrep
__initial_pt_6:    ; 2 MiB
    %assign i 2560
    %rep 512
    dq  i * 4096 + 0x103
    %assign i i + 1
    %endrep

[section .padata]
[global __initial_kernel_stack]
__initial_kernel_stack:
	times 0x1000 * (INITIAL_KSTACK_SIZE - 1) db 0	; 8 Pages

[section .rodata]
csNot64BitCapable:
	db "CPU does not support long-mode, please use the x86 build", 0