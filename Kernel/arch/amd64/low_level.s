[bits 64]
[global __sse_save]
[global __sse_enable]
[global __sse_restore]
[global __sse_disable]
[global __sse_initialize]

[global __read_rip]
[global __refresh_iretq]

[global __get_cr0]
[global __get_cr2]
[global __get_cr3]
[global __get_cr4]


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
	
__refresh_iretq:
	mov RAX, 0x10
	mov DS, AX
	mov ES, AX
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
		
__get_cr0:
    mov RAX, CR1
    ret

__get_cr2:
    mov RAX, CR2
    ret
	
__get_cr3:
    mov RAX, CR3
    ret

__get_cr4:
    mov RAX, CR4
    ret