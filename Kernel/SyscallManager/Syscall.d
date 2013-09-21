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

			// Set data registers
			mov AX, 0x10;
			mov DS, AX;
			mov ES, AX;
			mov FS, AX;
			mov GS, AX;
			mov SS, AX;

			call _CPU_swapgs;
			
		//	mov 16[GS], RSP;
			mov RSP, RAX;

			//push RAX;
			//mov RSP, RAX;
			//	mov [GS:16], RSP;
			//mov RSP, [GS:0];

			//GS.Kernel.Base: 0xCC56010

		//	push RCX;
		//cli; hlt;
		//	call SyscallDispatcher;
			cli; hlt;
		//	pop RCX;

			call _CPU_swapgs;
			sysret;
		}
	}

	extern(C) void SyscallDispatcher(ulong* data) {
		Log.Print("test");
	}
}