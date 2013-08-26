OUTPUT_FORMAT("binary")

kernel_VMA = 0x100000;

SECTIONS {
	. = kernel_VMA;

    .text :{
        code = .; _code = .; __code = .;
		*(.text)
        *(.text*)
		
        *(.rodata*)
		*(.rdata*)
    }

    .data :{
        data = .; _data = .; __data = .;
        *(.data)
		
  /*      start_ctors = .; 
		*(.ctor*) 
		end_ctors = .;
        
		start_dtors = .; 
		*(.dtor*) 
		end_dtors = .;*/
    }

    .bss :{
        sbss = .;
        bss = .; _bss = .; __bss = .;
        *(COMMON)
        *(.bss)
        ebss = .;
    }
	
	.ehframe :{
		ehframe = .;
		*(.ehframe)
	}
    end = .; _end = .; __end = .;
	
	_ekernel = .;
}
