[bits 16]

_install_gdt:
    pusha
    lgdt [GDT32.Pointer]
    popa
    ret

GDT32:
    .Null:
        dq 0x0000000000000000
    .Code:
        dq 0x00CF9A000000FFFF
        dq 0x00CF92000000FFFF
    .Code16:
        dq 0x008F9A000000FFFF
        dq 0x008F92000000FFFF
    .End:

    .Pointer:
        dw GDT32.End - GDT32 - 1
        dd GDT32