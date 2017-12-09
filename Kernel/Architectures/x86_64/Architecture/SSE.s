[bits 64]
[global __sse_save]
[global __read_rip] ; this shouldn't be there
[global __sse_enable]
[global __sse_restore]
[global __sse_disable]
[global __sse_initialize]

__sse_initialize:
	mov rax, cr4
	or ax, (1 << 9)|(1 << 10)
	mov cr4, rax
	mov rax, cr0
	and ax, ~(1 << 2)
	or rax, (1 << 1)
	mov rax, cr0
	ret

__sse_disable:
	mov rax, cr0
	or ax, 1 << 3
	mov cr0, rax
	ret

__sse_enable:
	mov rax, cr0
	and ax, ~(1 << 3)
	mov cr0, rax
	ret

__sse_save:
	fxsave [rdi]
	ret

__sse_restore:
	fxrstor [rdi]
	ret

__read_rip:
	pop rax
	jmp rax