module SyscallManager.Syscall;

import Architectures.CPU;
import Architectures.Port;
import SyscallManager.Res;


class Syscall {
static:
	struct Stack {
	align(1):
		ulong R15, R14, R13, R12, R11;
		ulong[]* Data;
		ulong R9, R8;
		ulong RBP, RDI, RSI, RDX, RCX, RBX, RAX;
	}

	enum Registers : ulong {
		IA32_STAR          = 0xc000_0081,
		IA32_LSTAR         = 0xc000_0082,
		IA32_FMASK         = 0xc000_0084,
		IA32_FS_BASE       = 0xc000_0100,
		IA32_GS_BASE       = 0xc000_0101,

		STAR               = 0x0013_0008_0000_0000
	}


	bool Init() {
		Port.WriteMSR(Registers.IA32_LSTAR, cast(ulong)&_CPU_syscall_handler);
		Port.WriteMSR(Registers.IA32_STAR, Registers.STAR);
		Port.WriteMSR(Registers.IA32_FMASK, 0x600);
		return true;
	}
}

extern(C) void SyscallDispatcher(Syscall.Stack* stack) {
	stack.RAX = Res.Call(stack.RAX, stack.RBX, *stack.Data);
}