module SyscallManager.Syscall;

import Core.Log;
import Architectures.CPU;
import Architectures.Port;
import MemoryManager.PageAllocator;
import MemoryManager.Memory;
import SyscallManager.Res;


class Syscall {
static:
	struct Stack {
	align(1):
		ulong R15, R14, R13, R12, R11, R10, R9, R8;
		ulong RBP, RDI, RSI, RDX, RCX, RBX, RAX;
		ulong Length;
		ulong* Data;
	}

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

			/*mov R9, RSP;
			call _CPU_swapgs;
			swapgs;
			mov R8, 0;
			lea R8, GS:[R8];*/

			push RAX;
			push RBX;
			push RCX;
			push RDX;
			push RSI;
			push RDI;
			push RBP;
			push R8;
			push R9;
			push R10;
			push R11;
			push R12;
			push R13;
			push R14;
			push R15;
			
			mov RDI, RSP;
			call SyscallDispatcher;

			pop R15;
			pop R14;
			pop R13;
			pop R12;
			pop R11;
			pop R10;
			pop R9;
			pop R8;
			pop RBP;
			pop RDI;
			pop RSI;
			pop RDX;
			pop RCX;
			pop RBX;
			pop RAX;

			//call _CPU_swapgs;
			sysret;
		}
	}

	extern(C) void SyscallDispatcher(Stack* stack) {
		ulong data[] = stack.Data[0 .. stack.Length];

		debug (only) {
			import System.Convert;
			Log.PrintSP("\n[Service RES: " ~ Convert.ToString(stack.RAX, 16));
			Log.PrintSP(", ID: " ~ Convert.ToString(stack.RBX, 16));

			foreach (x; data)
				Log.PrintSP(", " ~ Convert.ToString(x, 16));

			Log.PrintSP("]");
		}

		stack.RAX = Res.Call(stack.RAX, stack.RBX, data);
	}
}