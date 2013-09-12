[bits 16]

_enable_a20:
    mov     ax, 0x2401
    int     0x15

    cmp     ah, 0
    je      .end

    cli
    call    a20wait
    mov     al, 0xad
    out     0x64, al

    call    a20wait
    mov     al, 0xd0
    out     0x64, al

    call    a20wait2
    mov     al, 0x64
    push    eax

    call    a20wait
    mov     al, 0xd1
    out     0x64, al

    call    a20wait
    pop     eax
    or      al, 2
    out     0x60, al

    call    a20wait
    mov     al, 0xae
    out     0x64, al

    call    a20wait

    sti

    .end:
        ret

a20wait:
    in      al, 0x64
    test    al, 2
    jnz     a20wait
    ret
    
a20wait2:
    in      al, 0x64
    test    al, 1
    jz      a20wait2
    ret