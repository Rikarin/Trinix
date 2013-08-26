module MemoryManager.Memory;

import MemoryManager.PageAllocator;
import MemoryManager.Heap;

alias ubyte* PhysicalAddress;
alias ubyte* VirtualAddress;

import Core.Log;
extern(C) void* malloc(ulong size, uint ba) { if (Memory.test == 123456789) Log.PrintSP("$"); return cast(void *)PageAllocator.AllocPage(cast(uint)size / 0x1000); }
extern(C) void free(void *ptr) { if (Memory.test == 123456789) Log.PrintSP("#"); }


enum RegionType: ubyte {
	Reserved,
	Kernel,
}

struct Region {
	ulong Length;
	VirtualAddress VirtualStart;
	RegionType Type;
}
	

class Memory {
public:
static:
	__gshared PhysicalAddress Start;
	__gshared VirtualAddress VirtualStart;
	__gshared ulong Length;

	__gshared uint NumRegions;
	__gshared Region[16] RegionInfo;

	__gshared Heap KernelHeap;


	__gshared int test;
}
