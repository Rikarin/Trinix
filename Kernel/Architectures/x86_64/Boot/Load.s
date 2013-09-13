[section .text]
[bits 64]

extern StartSystem, apEntry, start_ctors, end_ctors
global start64

start64:
	mov RBP, _stack

	static_ctors_loop:
		mov rbx, start_ctors + 0x100000 ;need to fix
		jmp .test

		.body:
			call [rbx]
			add rbx, 8

		.test:
			cmp rbx, end_ctors
			jb .body

	call StartSystem


; we should not get here
haltloop:
	hlt
	jmp haltloop
	nop
	nop
	nop


global start64_ap
start64_ap:
	; Initialize the 64 bit stack pointer.
	;mov rsp, ((_stack - KERNEL_VMA_BASE) + STACK_SIZE)


	; RAX - the address to return to
	;mov rax, KERNEL_VMA_BASE >> 32
	shl rax, 32
	;or rax, long_entry_ap - (KERNEL_VMA_BASE & 0xffffffff00000000)
	push rax

	; Go into canonical higher half
	; It uses a trick to update the program counter
	; across a 64 bit address space
	ret

long_entry_ap:
	; From here on out, we are running instructions
	; within the higher half (0xffffffff80000000 ... )

	; We can safely upmap the lower half, we do not
	; need an identity mapping of this region

	; set up a 64 bit virtual stack
	;mov rax, KERNEL_VMA_BASE >> 32
	shl rax, 32
	;or rax, _stack - (KERNEL_VMA_BASE & 0xffffffff00000000)
	mov rsp, rax

	; set cpu flags
	push 0
	lss eax, [rsp]
	popf

	; set the input/output permission level to 3
	; it will allow all access

	pushf
	pop rax
	or rax, 0x3000
	push rax
	popf

	; clear rbp
	xor rbp, rbp

	; call StartSystem
	call apEntry


; stack space
global _stack
align 4096

_stack:
%rep 0x4000
dd 0
%endrep