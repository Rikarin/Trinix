[bits 64]
extern StartSystem
extern start_ctors, end_ctors, start_dtors, end_dtors

mov ax, 0x10
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax

static_ctors_loop:
	mov rbx, start_ctors
	jmp .test

	.body:
		call [rbx]
		add rbx, 8

	.test:
		cmp rbx, end_ctors
		jb .body

jmp StartSystem

;static_dtors_loop:
;	mov rbx, start_dtors
;	jmp .test
;
;	.body:
;		call [rbx]
;		add rbx, 8
;
;	.test:
;		cmp rbx, end_dtors
;		jb .body