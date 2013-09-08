module SyscallManager.Syscall;

import Core.Log;
import Architectures.CPU;
import Architectures.Port;
import MemoryManager.PageAllocator;
import MemoryManager.Memory;


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
		Port.WriteMSR(Registers.IA32_KERNEL_GSBASE, cast(ulong)(new byte[0x1000]).ptr + 0x1000);
		Port.WriteMSR(Registers.IA32_GS_BASE, cast(ulong)(new byte[0x1000]).ptr + 0x1000);

		return true;
	}

	void SyscallHandler() {
		asm {
			naked;
			call _CPU_swapgs;
			//	mov [GS:16], RSP;
			//mov RSP, [GS:0];

			//GS.Kernel.Base: 0xD8B010

			cli; hlt;

		//	push RCX;
			call SyscallDispatcher;
		//	pop RCX;

			call _CPU_swapgs;
			sysret;
		}
	}

	extern(C) void SyscallDispatcher(ulong* data) {
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