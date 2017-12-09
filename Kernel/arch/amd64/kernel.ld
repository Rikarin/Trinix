ENTRY(lstart)


__linker_kernel_start = 0xFFFFFFFF80000000;
lstart = start - __linker_kernel_start;


SECTIONS {
    . = SIZEOF_HEADERS;
    __load_addr = .;

    .multiboot : AT(ADDR(.multiboot)) {
        *(.multiboot)
    }

    . += 0x100000;
    . += __linker_kernel_start;

    .text ALIGN(0x1000) : AT(ADDR(.text) - __linker_kernel_start) {
        *(.text .text.*)
    }

    .rodata ALIGN(0x1000) : AT(ADDR(.rodata) - __linker_kernel_start) {
        *(.initpd)
        *(.rodata .rodata.*)
        *(.rdata)
    }

    .minfo ALIGN(0x1000) : AT(ADDR(.minfo) - __linker_kernel_start) {
        *(.minfo)
    }

    .deh_eh ALIGN(0x1000) : AT(ADDR(.deh_eh) - __linker_kernel_start) {
        *(.deh_eh)
    }
	
    .dtors.d_dso_dtor ALIGN(0x1000) : AT(ADDR(.dtors.d_dso_dtor) - __linker_kernel_start) {
		*(.dtors .dtors.*)
        *(.dtors.d_dso_dtor)
    }

    .ctors.d_dso_ctor ALIGN(0x1000) : AT(ADDR(.ctors.d_dso_ctor) - __linker_kernel_start) {
		*(.ctors .ctors.*)
        *(.ctors.d_dso_ctor)
    }

    .eh_frame ALIGN(0x1000) : AT(ADDR(.eh_frame) - __linker_kernel_start) {
        *(.eh_frame)
    }

    .data ALIGN(0x1000) : AT(ADDR(.data) - __linker_kernel_start) {
        *(.padata)
        *(.data .data.*)
    }
	
	.tdata ALIGN(0x1000) : AT(ADDR(.tdata) - __linker_kernel_start) {
		*(.tdata .tdata.*)
    }

    .got ALIGN(0x1000) : AT(ADDR(.got) - __linker_kernel_start) {
        *(.got)
        *(.got.plt)
    }

    .bss : AT(ADDR(.bss) - __linker_kernel_start) {
        __bss_start = .;
        *(.COMMON)
        *(.bss)
    }

    .tbss : AT(ADDR(.tbss) - __linker_kernel_start) {
        *(.tbss .tbss.*)
    }

    __linker_kernel_end = (. + 0xFFF) & 0xFFFFFFFFFFFFF000;

    /DISCARD/ : {
        *(.comment)
        *(.note .note.*)
        *(.rela.*)
    }
}