[global read_rip]
read_rip:
    pop rax
    jmp rax

[global idle_task]
idle_task:
    sti
    hlt
    jmp idle_task