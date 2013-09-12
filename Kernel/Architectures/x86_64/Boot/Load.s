; load.s

; entry is from boot.s

bits 64

; Everywhere you see some weird addition logic
; This is to fit the addresses into 32 bit sizes
; Note, they will sign extend!

section .text




; include useful definitions
; multiboot definitions
%define MULTIBOOT_HEADER_MAGIC 0x1BADB002
%define MULTIBOOT_HEADER_FLAGS 0x00010003

; where is the kernel?
%define KERNEL_VMA_BASE 0xFFFF800000000000
%define KERNEL_LMA_BASE 0x100000

; the gdt entry to use for the kernel
%define CS_KERNEL 0x10
%define CS_KERNEL32 0x08

; other definitions

%define STACK_SIZE 0x4000







;extern StartSystem
;extern apEntry

global start64

start64:

; Initialize the 64 bit stack pointer.
mov rsp, ((_stack - KERNEL_VMA_BASE) + STACK_SIZE)

; Set up the stack for the return.
push CS_KERNEL

; RAX - the address to return to
mov rax, KERNEL_VMA_BASE >> 32
shl rax, 32
or rax, long_entry - (KERNEL_VMA_BASE & 0xffffffff00000000)
push rax

; Go into canonical higher half
; It uses a trick to update the program counter
; across a 64 bit address space
ret

long_entry:

; From here on out, we are running instructions
; within the higher half (0xffffffff80000000 ... )

; We can safely upmap the lower half, we do not
; need an identity mapping of this region

; set up a 64 bit virtual stack
mov rax, KERNEL_VMA_BASE >> 32
shl rax, 32
or rax, _stack - (KERNEL_VMA_BASE & 0xffffffff00000000)
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

; update the multiboot struct to point to a
; virtual address
add rsi, (KERNEL_VMA_BASE & 0xffffffff)

; push the parameters (just in case)
push rsi
push rdi

; clear rbp
xor rbp, rbp

; call StartSystem
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
mov rsp, ((_stack - KERNEL_VMA_BASE) + STACK_SIZE)

; Set up the stack for the return.
push CS_KERNEL

; RAX - the address to return to
mov rax, KERNEL_VMA_BASE >> 32
shl rax, 32
or rax, long_entry_ap - (KERNEL_VMA_BASE & 0xffffffff00000000)
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
mov rax, KERNEL_VMA_BASE >> 32
shl rax, 32
or rax, _stack - (KERNEL_VMA_BASE & 0xffffffff00000000)
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

; end

; stack space
global _stack
align 4096

_stack:
%rep STACK_SIZE
dd 0
%endrep

[bits 64]
StartSystem:
apEntry:
jmp $