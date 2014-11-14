[bits 64]
[global _CPU_refresh_iretq]

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