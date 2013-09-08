module SyscallManager.Syscall;

import Core.Log;
import Architectures.Port;
import MemoryManager.PageAllocator;
import MemoryManager.Memory;


class Syscall {
static:
	enum Registers : ulong {
		FSBASE_MSR = 0xc000_0100,
		GSBASE_MSR = 0xc000_0101,
		STAR_MSR   = 0xc000_0081,
		LSTAR_MSR  = 0xc000_0082,
		SFMASK_MSR = 0xc000_0084,
		STAR       = 0x001B_0008_0000_0000
	}

	void Init() {
		Port.WriteMSR(Registers.LSTAR_MSR, cast(ulong)&SyscallHandler);
		Port.WriteMSR(Registers.STAR_MSR, Registers.STAR);
		Port.WriteMSR(Registers.SFMASK_MSR, 0);
		Port.WriteMSR(Registers.GSBASE_MSR, cast(ulong)(new byte[0x1000]).ptr + 0x1000);


	}

	void SyscallHandler() {
		asm {
			naked;

			push RCX;
			call SyscallDispatcher;
			pop RCX;
			sysret;
		}
	}

	/*
struct InterruptStack {
align(1):
	ulong R15, R14, R13, R12, R11, R10, R9, R8;
	ulong RBP, RDI, RSI, RDX, RCX, RBX, RAX;
	ulong IntNumber, ErrorCode;
	ulong RIP, CS, Flags, RSP, SS;
}
	*/

	extern(C) void SyscallDispatcher(ulong ID, void* ret, void* params) {
		Log.Print("test");
	// RCX holds the return address for the system call, which is useful
	// for certain system calls (such as fork)

	//void* stackPtr;
	//asm {
	// "movq %%rsp, %%rax" ::: "rax";
	// "movq %%rax, %0" :: "o" stackPtr : "rax";
	//}//
	//kprintfln!("Syscall: ID = 0x{x}, ret = 0x{x}, params = 0x{x}")(ID, ret, params);
	//mixin(MakeSyscallDispatchList!());
	}
}