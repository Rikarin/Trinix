module MemoryManager.Memory;

import Core;
import MemoryManager;

import System;

alias ubyte* PhysicalAddress;
alias ubyte* VirtualAddress;

extern(C) void* malloc(ulong size, uint ba) {
//	Log.PrintSP("$");
	return PageAllocator.IsInit ? Memory.KernelHeap.Alloc(size) : cast(void *)PageAllocator.AllocPage(cast(uint)size / 0x1000);
}

extern(C) void free(void* ptr) { return;
	if (PageAllocator.IsInit)
		Memory.KernelHeap.Free(ptr);
}


enum RegionType: uint {
	Free = 1,
	Reserved,
	ACPI_ReclaimableMemory,
	ACPI_NVS_Memory,
	BadMemory,
	ISA_DMA_Memory,
	Kernel,
	Initrd,
	VideoBackbuffer
}

struct Region {
	VirtualAddress VirtualStart;
	ulong Length;
	RegionType Type;
	uint ExtendAddress;
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


	bool LoadMemoryRegions() {
		NumRegions = *cast(uint *)(0x7CC9 + VirtualStart) & 0xFF;
		Region* tmp = cast(Region *)(0x7000 + VirtualStart);

		foreach (i; 0 .. NumRegions)
			RegionInfo[i] = tmp[i];

		return true;
	}

	void PrintMemoryRegions() {
	    Log.Print("|--------------------|------------|-----------------------------|\n");
	    Log.Print("| Base address | Length | Type |\n");
	    Log.Print("|--------------------|------------|-----------------------------|\n");
	    
	    foreach (i; 0 .. NumRegions) {
	        Log.Print("| " ~ Convert.ToString(cast(ulong)RegionInfo[i].VirtualStart, 16) ~ " | " ~ Convert.ToString(RegionInfo[i].Length, 16) ~ " | ");
	        
	        switch (RegionInfo[i].Type) {
	            case RegionType.Free:
	                Log.Print("Free memory ");
	                break;
	            case RegionType.Reserved:
	                Log.Print("Reserved memory ");
	                break;
	            case RegionType.ACPI_ReclaimableMemory:
	                Log.Print("ACPI reclaimable memory ");
	                break;
	            case RegionType.ACPI_NVS_Memory:
	                Log.Print("ACPI NVS memory ");
	                break;
	            case RegionType.BadMemory:
	                Log.Print("Bad memory ");
	                break;
	            case RegionType.ISA_DMA_Memory:
	                Log.Print("ISA DMA memory ");
	                break;
	            case RegionType.Kernel:
	                Log.Print("Kernel memory ");
	                break;
	            case RegionType.Initrd:
	                Log.Print("Initrd memory ");
	                break;
	            case RegionType.VideoBackbuffer:
	                Log.Print("Video backbuffer ");
	                break;
               	default:
	               break;
	        }
	        Log.Print(" | \n");
	    }
	    
	    Log.Print("|--------------------|------------|-----------------------------|\n");
	}
}
