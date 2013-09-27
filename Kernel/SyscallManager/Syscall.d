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

		STAR               = 0x001B_0008_0000_0000
	}


	bool Init() {
		Port.WriteMSR(Registers.IA32_LSTAR, cast(ulong)&_CPU_syscall_handler);
		Port.WriteMSR(Registers.IA32_STAR, Registers.STAR);
		Port.WriteMSR(Registers.IA32_FMASK, 0x600);
		return true;
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

extern(C) void SyscallDispatcher(Syscall.Stack* stack) {
	Syscall.SyscallDispatcher(stack);
}