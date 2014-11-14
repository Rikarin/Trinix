OUTPUT_FORMAT(elf64-x86-64)
ENTRY(lstart)


_kernel_base = 0xFFFFFFFF80000000;
lstart = start - _kernel_base;


SECTIONS {
    . = SIZEOF_HEADERS;
    __load_addr = .;

    .multiboot : AT(ADDR(.multiboot)) {
        *(.multiboot)
    }

    . += 0x100000;
    . += _kernel_base;
	iKernelBase = _kernel_base;

    .text ALIGN(0x1000) : AT(ADDR(.text) - _kernel_base) {
        *(.text .text.*)
    }

    .rodata ALIGN(0x1000) : AT(ADDR(.rodata) - _kernel_base) {
        *(.initpd)
        *(.rodata .rodata.*)
        *(.rdata)
    }

    .minfo ALIGN(0x1000) : AT(ADDR(.minfo) - _kernel_base) {
        *(.minfo)
    }

    .deh_eh ALIGN(0x1000) : AT(ADDR(.deh_eh) - _kernel_base) {
        *(.deh_eh)
    }

    .minfo ALIGN(0x1000) : AT(ADDR(.minfo) - _kernel_base) {
        *(.minfo)
    }

    .dtors.d_dso_dtor ALIGN(0x1000) : AT(ADDR(.dtors.d_dso_dtor) - _kernel_base) {
        *(.dtors.d_dso_dtor)
    }

    .ctors.d_dso_ctor ALIGN(0x1000) : AT(ADDR(.ctors.d_dso_ctor) - _kernel_base) {
        *(.ctors.d_dso_ctor)
    }

    .eh_frame ALIGN(0x1000) : AT(ADDR(.eh_frame) - _kernel_base) {
        *(.eh_frame)
    }

    .data ALIGN(0x1000) : AT(ADDR(.data) - _kernel_base) {
        *(.padata)
        *(.data .data.*)
    }

    .got ALIGN(0x1000) : AT(ADDR(.got) - _kernel_base) {
        *(.got)
        *(.got.plt)
    }

    .bss : AT(ADDR(.bss) - _kernel_base) {
        __bss_start = .;
        *(.COMMON)
        *(.bss)
    }

    .tbss : AT(ADDR(.tbss) - _kernel_base) {
        *(.tbss)
    }

    iKernelEnd = (. + 0xFFF) & 0xFFFFFFFFFFFFF000;

    /DISCARD/ :
    {
        *(.comment)
        *(.note .note.*)
        *(.rela.*)
    }
}