module SyscallManager.Syscall;

import Core.Log;
import Architectures.CPU;
import Architectures.Port;
import MemoryManager.PageAllocator;
import MemoryManager.Memory;
import SyscallManager.Res;


class Syscall {
static:
	enum Registers : ulong {
		IA32_STAR          = 0xc000_0081,
		IA32_LSTAR         = 0xc000_0082,
		IA32_FMASK         = 0xc000_0084,
		IA32_FS_BASE       = 0xc000_0100,
		IA32_GS_BASE       = 0xc000_0101,
		IA32_KERNEL_GSBASE = 0xc000_0102,

		STAR               = 0x001B_0008_0000_0000
	}


	bool Init() {
		Port.WriteMSR(Registers.IA32_LSTAR, cast(ulong)&SyscallHandler);
		Port.WriteMSR(Registers.IA32_STAR, Registers.STAR);
		Port.WriteMSR(Registers.IA32_FMASK, 0);
		Port.WriteMSR(Registers.IA32_KERNEL_GSBASE, cast(ulong)0xC010000);//(new byte[0x1000]).ptr + 0x1000);
		Port.WriteMSR(Registers.IA32_GS_BASE, cast(ulong)0xC020000);//(new byte[0x1000]).ptr + 0x1000);

		return true;
	}

	void SyscallHandler() {
		asm {
			naked;

			mov R9, RSP;

			call _CPU_swapgs;
			swapgs;
			mov R8, 0;
			lea R8, GS:[R8];

			cli;hlt;

			push RDX;
			push RCX;
			push RBX;
			push RAX;
			
			mov RDI, RSP;
			call SyscallDispatcher;

			pop RBX;
			pop RBX;
			pop RCX;
			pop RDX;

			//cli;hlt;

			//call _CPU_swapgs;
			sysret;
		}
	}

	extern(C) void SyscallDispatcher(ulong*rawData) {
		ulong data[] = (cast(ulong *)rawData[5])[0 .. rawData[4]];

		debug (only) {
			import System.Convert;
			Log.PrintSP("\n[Service RES: " ~ Convert.ToString(rawData[0], 16));
			Log.PrintSP(", ID: " ~ Convert.ToString(rawData[1], 16));

			foreach (x; data)
				Log.PrintSP(", " ~ Convert.ToString(x, 16));

			Log.PrintSP("]");
		}

		//return 0x123;//Res.Call(rawData[0], rawData[1], data);
	}
}