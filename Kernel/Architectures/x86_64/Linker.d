module Architectures.x86_64.Linker;

extern(C) __gshared {
	ubyte kernel_VMA;
	
	ubyte _ekernel;
	ubyte _code;
	ubyte _data;
	ubyte _bss;
	
	ubyte _start_ctors;
	ubyte _end_ctors;
	
	ubyte _start_dtors;
	ubyte _end_dtors;
}


class LinkerScript {
public:
static:
	void* EndKernel()   { return &_ekernel; }
	void* Code()        { return &_code; }
	void* Data()        { return &_data; }
	void* Bss()         { return &_bss; }
	
	void* StartCtors()  { return &_start_ctors; }
	void* EndCtors()    { return &_end_ctors; }
	void* StartDtors()  { return &_start_dtors; }
	void* EndDtors()    { return &_end_dtors; }
	void* KernelVMA()   { return &kernel_VMA; }
}