module Architectures.x86_64.Linker;

extern(C) __gshared
{
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


class LinkerScript
{
public:
static:
	void* ekernel()
	{
		return &_ekernel;
	}
	
	
	void* code()
	{
		return &_code;
	}
	
	
	void* data()
	{
		return &_data;
	}
	
	
	void* bss()
	{
		return &_bss;
	}
	
	
	void* start_ctors()
	{
		return &_start_ctors;
	}
	
	
	void* end_ctors()
	{
		return &_end_ctors;
	}
	
	
	void* start_dtors()
	{
		return &_start_dtors;
	}
	
	
	void* end_dtors()
	{
		return &_end_dtors;
	}
	
	
	void* kernelVMA()
	{
		return cast(void *)kernel_VMA;
	}
}