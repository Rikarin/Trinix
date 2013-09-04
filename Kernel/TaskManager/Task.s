[GLOBAL read_rip]
read_rip:
    pop rax
    jmp rax

[GLOBAL idle_task]
idle_task:
    sti
    hlt
    jmp idle_task