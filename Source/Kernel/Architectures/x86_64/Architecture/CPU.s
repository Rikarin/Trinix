[bits 64]
[global _CPU_refresh_iretq]
[global _CPU_syscall_handler]

[extern SyscallDispatcher]

_CPU_refresh_iretq:
	mov RAX, 0x10
	mov DS, AX
	mov ES, AX
	mov FS, AX
	mov GS, AX
	mov SS, AX

	mov RDX, RSP
	push RAX
	push RDX
	pushfq
	push 0x08

	mov RAX, .r
	push RAX
	iretq

	.r:
		ret

_CPU_syscall_handler:
	cli
	hlt
	swapgs
	mov [GS:0], RSP
	mov RSP, [GS:8]
	swapgs
	sti

	push RAX
	push RBX
	push RCX
	push RDX
	push RSI
	push RDI
	push RBP
	push R8
	push R9
	push R10
	push R11
	push R12
	push R13
	push R14
	push R15

	mov RDI, RSP
	call SyscallDispatcher

	pop R15
	pop R14
	pop R13
	pop R12
	pop R11
	pop R10
	pop R9
	pop R8
	pop RBP
	pop RDI
	pop RSI
	pop RDX
	pop RCX
	pop RBX
	pop RAX

	cli
	swapgs
	mov RSP, [GS:0]
	swapgs
	sti

	o64 sysret