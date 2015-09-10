SECTIONS {
    . = SIZEOF_HEADERS;

    .text ALIGN(0x1000) : AT(ADDR(.text)) {
        *(.text .text.*)
    }

    .rodata ALIGN(0x1000) : AT(ADDR(.rodata)) {
        *(.initpd)
        *(.rodata .rodata.*)
        *(.rdata)
    }

    .minfo ALIGN(0x1000) : AT(ADDR(.minfo)) {
        *(.minfo)
    }

    .deh_eh ALIGN(0x1000) : AT(ADDR(.deh_eh)) {
        *(.deh_eh)
    }
	
    .dtors.d_dso_dtor ALIGN(0x1000) : AT(ADDR(.dtors.d_dso_dtor)) {
		*(.dtors .dtors.*)
        *(.dtors.d_dso_dtor)
    }

    .ctors.d_dso_ctor ALIGN(0x1000) : AT(ADDR(.ctors.d_dso_ctor)) {
		*(.ctors .ctors.*)
        *(.ctors.d_dso_ctor)
    }

    .eh_frame ALIGN(0x1000) : AT(ADDR(.eh_frame)) {
        *(.eh_frame)
    }

    .data ALIGN(0x1000) : AT(ADDR(.data)) {
        *(.padata)
        *(.data .data.*)
    }
	
    .KMODULES : {
		*/DriverInfo.d.o (.rodata.*)
    }
	
	.symbols ALIGN(0x1000) : AT(ADDR(.symbols)) {
		*(.symbols .symbols.*)
    }
	
	.tdata ALIGN(0x1000) : AT(ADDR(.tdata)) {
		*(.tdata .tdata.*)
    }

    .got ALIGN(0x1000) : AT(ADDR(.got)) {
        *(.got)
        *(.got.plt)
    }

    .bss : AT(ADDR(.bss)) {
        *(.COMMON)
        *(.bss)
    }

    .tbss : AT(ADDR(.tbss)) {
        *(.tbss)
    }


    /DISCARD/ : {
        *(.comment)
        *(.note .note.*)
    }
}