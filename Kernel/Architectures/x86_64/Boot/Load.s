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

[bits 64]

%define INITIAL_KSTACK_SIZE	8
KERNEL_BASE	equ	0xFFFFFFFF80000000

[extern ArchMain]

[extern __multiboot_ptr]
[extern __multiboot_magic]

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
	mov edi, [__multiboot_magic - KERNEL_BASE]
	mov esi, [__multiboot_ptr - KERNEL_BASE]
	call ArchMain
	
	cli
.hlt:
	hlt
	jmp .hlt