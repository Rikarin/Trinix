[bits 64]
[global _Proc_SaveSSE]
[global _Proc_Read_RIP]
[global _Proc_EnableSSE]
[global _Proc_RestoreSSE]
[global _Proc_DisableSSE]
[global _Proc_InitialiseSSE]


_Proc_InitialiseSSE:
	mov rax, cr4
	or ax, (1 << 9)|(1 << 10)
	mov cr4, rax
	mov rax, cr0
	and ax, ~(1 << 2)
	or rax, (1 << 1)
	mov rax, cr0
	ret


_Proc_DisableSSE:
	mov rax, cr0
	or ax, 1 << 3
	mov cr0, rax
	ret


_Proc_EnableSSE:
	mov rax, cr0
	and ax, ~(1 << 3)
	mov cr0, rax
	ret


_Proc_SaveSSE:
	fxsave [rdi]
	ret


_Proc_RestoreSSE:
	fxrstor [rdi]
	ret


_Proc_Read_RIP:
	pop rax
	jmp rax