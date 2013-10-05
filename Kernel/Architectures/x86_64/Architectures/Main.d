module Architectures.Main;

import Architectures.CPU;
import Architectures.x86_64.Linker;
import Architectures.x86_64.Core.GDT;
import Architectures.x86_64.Core.TSS;
import Architectures.x86_64.Core.IDT;
import Architectures.x86_64.Core.Info;

import MemoryManager.PageAllocator;
import MemoryManager.Memory;
import Core.Log;

class Architecture {
public:
static:
	void Init() {
		Memory.Start = null;
		Memory.Length = cast(ulong)LinkerScript.EndKernel() - cast(ulong)LinkerScript.KernelVMA() + 0x1000;
		Memory.VirtualStart = cast(ubyte *)LinkerScript.KernelVMA();

		Info.NumIOAPICs = 0;
		Info.NumLAPICs = 0;
		
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
