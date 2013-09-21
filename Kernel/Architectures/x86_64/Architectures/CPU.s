bits 64
global _CPU_refresh_iretq
global _CPU_iretq
global _CPU_lidt
global _CPU_load_cr3
global _CPU_swapgs


_CPU_refresh_iretq:
	mov RAX, 0x10
	mov DS, AX
	mov ES, AX
	mov FS, AX
	mov GS, AX
	
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

_CPU_iretq:
	iretq

_CPU_swapgs:
	swapgs
	mov RAX, [GS:0]
	ret