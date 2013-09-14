OUTPUT_FORMAT(binary)
ENTRY(_start)

kernel_VMA = 0xC000000;
kernel_LMA = 0x100000;


SECTIONS {
	. = kernel_LMA;

    .text_boot : {
        Obj/Kernel/Architectures/x86_64/Boot/Boot.s.o (.text)
    }

    . += kernel_VMA;


    .text : AT(ADDR(.text) - kernel_VMA) {
        _code = .;
		*(.text)
        *(.text*)
		
        *(.rodata*)
		*(.rdata*)

        . = ALIGN(4096);
    }

    _etext = .; PROVIDE(etext = .);


    .data : AT(ADDR(.data) - kernel_VMA) {
        _data = .;

        *(.data)
		
        start_ctors = .; 
		*(.ctor*) 
		end_ctors = .;
        
		start_dtors = .; 
		*(.dtor*) 
		end_dtors = .;

        . = ALIGN(4096);
    }

    _edata = .; PROVIDE (edata = .);


    .bss : AT(ADDR(.bss) - kernel_VMA) {
        _bss = .;

        *(.bss)

        . = ALIGN(4096);
    }

    _ebss = .;
    ebss = .;

	
	.ehframe : AT(ADDR(.ehframe) - kernel_VMA) {
		ehframe = .;
		*(.ehframe)

        . = ALIGN(4096);
	}

    _end = .; PROVIDE (end = .);
	_ekernel = .;
}