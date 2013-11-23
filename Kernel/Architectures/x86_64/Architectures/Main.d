module Architectures.Main;

import Core;
import Architectures;
import MemoryManager;

class Architecture {
public:
static:
	void Init() {
		Memory.Start = null;
		Memory.Length = cast(ulong)LinkerScript.EndKernel() - cast(ulong)LinkerScript.KernelVMA() + 0x1000;
		Memory.VirtualStart = cast(ubyte *)LinkerScript.KernelVMA();

		PageAllocator.Init();
		Log.Result(true);

		//Get memory map
		Log.Print(" - Loading memory regions");
		//Log.Result(Memory.LoadMemoryRegions());
		Log.Result(false);
		
		//GDT
		Log.Print(" - Initializing GDT");
		Log.Result(GDT.Init());
		
		//TSS
		Log.Print(" - Initializing TSS");
		Log.Result(TSS.Init());
		
		//IDT
		Log.Print(" - Initializing IDT");
		Log.Result(IDT.Init());
		
		//CPU
		Log.Print(" - Getting cache info");
		CPU.GetCacheInfo();
		Log.Result(true);
	}
}
