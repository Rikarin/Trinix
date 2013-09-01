module Architectures.CPU;

import Core.Log;
import MemoryManager.PageAllocator;
import Architectures.Port;
import Architectures.Multiprocessor;
import Architectures.x86_64.Core.GDT;
import Architectures.x86_64.Core.TSS;
import Architectures.x86_64.Core.IDT;
import Architectures.x86_64.Core.LocalAPIC;

extern(C) void _CPU_iretq();
extern(C) void _CPU_refresh_iretq();
extern(C) void _CPU_load_cr3();

class CPU {
public:
static:
	__gshared Processor[256] ProcessorInfo;
	__gshared private ubyte* Stacks[256];
	
	
	struct Cache {
		uint Associativity;
		uint Length;
		uint BlockSize;
		uint LinesPerSector;
	}

	struct Processor {
		Cache L1ICache;
		Cache L1DCache;
		Cache L2Cache;
		Cache L3Cache;
	}

	
	void Init() {
		Log.Result(true);
		
		Log.Print(" - Enabling NX support");
		Port.WriteMSR(0xC0000080, Port.ReadMSR(0xC0000080) | 0x800UL);
		Log.Result(true);
		
		Log.Print(" - Verifying PC");
		Log.Result(Verify());

		Log.Print(" - Installing GDT");
		Log.Result(GDT.Install());
		
		Log.Print(" - Installing TSS");
		Log.Result(TSS.Install());
		
		Log.Print(" - Installing IDT");
		Log.Result(IDT.Install());
		
		Log.Print(" - Installing stack");
		Log.Result(InstallStack());
		
		Log.Print(" - Enabling FPU");
		Port.EnableFPU();
		Log.Result(true);
	}
	
	@property uint Identifier() {
		return Multiprocessor.CPUCount ? LocalAPIC.Identifier : 0;
	}
	
	void GetCacheInfo() {
		uint eax, ebx, ecx, edx;
		uint count, temp;
		ulong saveRBX;
		
		asm {
			mov saveRBX, RBX;
		}
		
		eax = Port.cpuidAX(0x02);
		ebx = Port.GetBX();
		ecx = Port.GetCX();
		edx = Port.GetDX();
		count = eax & 0xFF;
		
		for (uint i = 0; i < count; i++) {
			temp = (eax >> 31) & 1;
			if (!temp)
				ExamineRegister(eax);
				
			temp = (ebx >> 31) & 1;
			if (!temp)
				ExamineRegister(ebx);
				
			temp = (ecx >> 31) & 1;
			if (!temp)
				ExamineRegister(ecx);
			
			temp = (edx >> 31) & 1;
			if (!temp)
				ExamineRegister(edx);
				
			eax = Port.cpuidAX(0x02);
			ebx = Port.GetBX();
			ecx = Port.GetCX();
			edx = Port.GetDX();
		}
		
		asm {
			mov RBX, saveRBX;
		}
	}
	
	void ExamineRegister(uint reg) {
		for(uint i = 0; i < 4; i++)  {
			uint temp = reg >> (8 * i);
			temp = temp & 0xFF;
			
			switch(temp) {
				case 0x06:
					ProcessorInfo[Identifier].L1ICache.Length = 8192;
					ProcessorInfo[Identifier].L1ICache.Associativity = 4;
					ProcessorInfo[Identifier].L1ICache.BlockSize = 32;
					break;
				case 0x08:
					ProcessorInfo[Identifier].L1ICache.Length = 16384;
					ProcessorInfo[Identifier].L1ICache.Associativity = 4;
					ProcessorInfo[Identifier].L1ICache.BlockSize = 32;
					break;
				case 0x09:
					ProcessorInfo[Identifier].L1ICache.Length = 16384;
					ProcessorInfo[Identifier].L1ICache.Associativity = 4;
					ProcessorInfo[Identifier].L1ICache.BlockSize = 64;
					break;
				case 0x0A:
					ProcessorInfo[Identifier].L1DCache.Length = 8192;
					ProcessorInfo[Identifier].L1DCache.Associativity = 2;
					ProcessorInfo[Identifier].L1DCache.BlockSize = 32;
					break;
				case 0x0C:
					ProcessorInfo[Identifier].L1DCache.Length = 16384;
					ProcessorInfo[Identifier].L1DCache.Associativity = 4;
					ProcessorInfo[Identifier].L1DCache.BlockSize = 32;
					break;
				case 0x0D:
					ProcessorInfo[Identifier].L1DCache.Length = 16384;
					ProcessorInfo[Identifier].L1DCache.Associativity = 4;
					ProcessorInfo[Identifier].L1DCache.BlockSize = 64;
					break;
				case 0x0E:
					ProcessorInfo[Identifier].L1DCache.Length = 24576;
					ProcessorInfo[Identifier].L1DCache.Associativity = 6;
					ProcessorInfo[Identifier].L1DCache.BlockSize = 64;
					break;
				case 0x21:
					ProcessorInfo[Identifier].L2Cache.Length = 262144;
					ProcessorInfo[Identifier].L2Cache.Associativity = 8;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 64;
					break;
				case 0x2C:
					ProcessorInfo[Identifier].L1DCache.Length = 32768;
					ProcessorInfo[Identifier].L1DCache.Associativity = 8;
					ProcessorInfo[Identifier].L1DCache.BlockSize = 64;
					break;
				case 0x30:
					ProcessorInfo[Identifier].L1ICache.Length = 32768;
					ProcessorInfo[Identifier].L1ICache.Associativity = 8;
					ProcessorInfo[Identifier].L1ICache.BlockSize = 64;
					break;
				case 0x41:
					ProcessorInfo[Identifier].L2Cache.Length = 131072;
					ProcessorInfo[Identifier].L2Cache.Associativity = 4;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 32;
					break;
				case 0x42:
					ProcessorInfo[Identifier].L2Cache.Length = 262144;
					ProcessorInfo[Identifier].L2Cache.Associativity = 4;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 32;
					break;
				case 0x43:
					ProcessorInfo[Identifier].L2Cache.Length = 524288;
					ProcessorInfo[Identifier].L2Cache.Associativity = 4;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 32;
					break;
				case 0x44:
					ProcessorInfo[Identifier].L2Cache.Length = 1048576;
					ProcessorInfo[Identifier].L2Cache.Associativity = 4;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 32;
					break;
				case 0x45:
					ProcessorInfo[Identifier].L2Cache.Length = 2097152;
					ProcessorInfo[Identifier].L2Cache.Associativity = 4;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 32;
					break;
				case 0x48:
					ProcessorInfo[Identifier].L2Cache.Length = 3145728;
					ProcessorInfo[Identifier].L2Cache.Associativity = 12;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 64;
					break;
				case 0x60:
					ProcessorInfo[Identifier].L1DCache.Length = 16384;
					ProcessorInfo[Identifier].L1DCache.Associativity = 8;
					ProcessorInfo[Identifier].L1DCache.BlockSize = 64;
					break;
				case 0x66:
					ProcessorInfo[Identifier].L1DCache.Length = 8192;
					ProcessorInfo[Identifier].L1DCache.Associativity = 4;
					ProcessorInfo[Identifier].L1DCache.BlockSize = 64;
					break;
				case 0x67:
					ProcessorInfo[Identifier].L1DCache.Length = 16384;
					ProcessorInfo[Identifier].L1DCache.Associativity = 4;
					ProcessorInfo[Identifier].L1DCache.BlockSize = 64;
					break;
				case 0x68:
					ProcessorInfo[Identifier].L1DCache.Length = 32768;
					ProcessorInfo[Identifier].L1DCache.Associativity = 4;
					ProcessorInfo[Identifier].L1DCache.BlockSize = 64;
					break;
				case 0x78:
					ProcessorInfo[Identifier].L2Cache.Length = 1048576;
					ProcessorInfo[Identifier].L2Cache.Associativity = 4;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 64;
					break;
				case 0x79:
					ProcessorInfo[Identifier].L2Cache.Length = 131072;
					ProcessorInfo[Identifier].L2Cache.Associativity = 8;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 64;
					ProcessorInfo[Identifier].L2Cache.LinesPerSector = 2;
					break;
				case 0x7A:
					ProcessorInfo[Identifier].L2Cache.Length = 262144;
					ProcessorInfo[Identifier].L2Cache.Associativity = 8;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 64;
					ProcessorInfo[Identifier].L2Cache.LinesPerSector = 2;
					break;
				case 0x7B:
					ProcessorInfo[Identifier].L2Cache.Length = 524288;
					ProcessorInfo[Identifier].L2Cache.Associativity = 8;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 64;
					ProcessorInfo[Identifier].L2Cache.LinesPerSector = 2;
					break;
				case 0x7C:
					ProcessorInfo[Identifier].L2Cache.Length = 1048576;
					ProcessorInfo[Identifier].L2Cache.Associativity = 8;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 64;
					ProcessorInfo[Identifier].L2Cache.LinesPerSector = 2;
					break;
				case 0x7D:
					ProcessorInfo[Identifier].L2Cache.Length = 2097152;
					ProcessorInfo[Identifier].L2Cache.Associativity = 8;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 64;
					break;
				case 0x7F:
					ProcessorInfo[Identifier].L2Cache.Length = 524288;
					ProcessorInfo[Identifier].L2Cache.Associativity = 2;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 64;
					break;
				case 0x80:
					ProcessorInfo[Identifier].L2Cache.Length = 524288;
					ProcessorInfo[Identifier].L2Cache.Associativity = 8;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 64;
					break;
				case 0x82:
					ProcessorInfo[Identifier].L2Cache.Length = 262144;
					ProcessorInfo[Identifier].L2Cache.Associativity = 3;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 32;
					break;
				case 0x83:
					ProcessorInfo[Identifier].L2Cache.Length = 524288;
					ProcessorInfo[Identifier].L2Cache.Associativity = 8;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 32;
					break;
				case 0x84:
					ProcessorInfo[Identifier].L2Cache.Length = 1048576;
					ProcessorInfo[Identifier].L2Cache.Associativity = 8;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 32;
					break;
				case 0x85:
					ProcessorInfo[Identifier].L2Cache.Length = 2097152;
					ProcessorInfo[Identifier].L2Cache.Associativity = 8;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 32;
					break;
				case 0x86:
					ProcessorInfo[Identifier].L2Cache.Length = 524288;
					ProcessorInfo[Identifier].L2Cache.Associativity = 4;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 64;
					break;
				case 0x87:
					ProcessorInfo[Identifier].L2Cache.Length = 1048576;
					ProcessorInfo[Identifier].L2Cache.Associativity = 8;
					ProcessorInfo[Identifier].L2Cache.BlockSize = 64;
					break;
				default:
					break;
			}
		}
		return;
	}
	
	bool Verify() {
		if (!(Port.cpuidDX(0x80000001) & 0b100000000000))
			return false;
		return true;
	}
	
	bool InstallStack() {
		ubyte* stack = PageAllocator.AllocPage();
		ubyte* currentStack = cast(ubyte *)0x19000 - 0x1000;
		
		stack[0 .. 0x1000] = currentStack[0 .. 0x1000];
		Stacks[Identifier] = cast(ubyte *)stack + 0x1000;
		TSS.Table.RSP0 = Stacks[Identifier];


		asm {
			naked;
			mov RAX, RSP;
			and RAX, 0xFFF;
			add RAX, stack;
			mov RSP, RAX;

			mov RAX, RBP;
			and RAX, 0xFFF;
			add RAX, stack;
			mov RBP, RAX;

			ret;
		}

		return true;
	}
}
