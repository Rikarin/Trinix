OUTPUT_FORMAT(binary)
ENTRY(_start)

kernel_VMA = 0xC000000;
kernel_LMA = 0x100000;


SECTIONS {
	. = kernel_LMA;

    _kernelLMA = .;


    _boot = .;

    .text_boot : {
        Obj/Kernel/Architectures/x86_64/Boot/Boot.s.o (.text)
    }
    _eboot = .;



    . = . + kernel_VMA;

    _text = .;
    _kernel = .;
    _kernelVMA = kernel_VMA;


    .text : AT(ADDR(.text) - kernel_VMA + kernel_LMA) {
        code = .;
		*(.text)
        *(.text*)
		
        *(.rodata*)
		*(.rdata*)

        . = ALIGN(4096);
    }

    _etext = .; PROVIDE(etext = .);


    .data : AT(ADDR(.data) - kernel_VMA + kernel_LMA) {
        data = .;
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



    .bss : AT(ADDR(.bss) - kernel_VMA + kernel_LMA) {
        sbss = .;
        bss = .; 
        _bss = .;

        *(.bss)

        . = ALIGN(4096);
    }

    _ebss = .;
    ebss = .;

	
	.ehframe : AT(ADDR(.ehframe) - kernel_VMA + kernel_LMA) {
		ehframe = .;
		*(.ehframe)

        . = ALIGN(4096);
	}

    _end = .; PROVIDE (end = .);
	_ekernel = .;
}
