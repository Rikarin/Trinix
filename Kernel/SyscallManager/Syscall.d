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
		STAR       = 0x003b_0010_0000_0000,
		STAR2      = 0x0810_0810_0000_0000
	}

	void Init() {
		Port.WriteMSR(Registers.LSTAR_MSR, cast(ulong)&SyscallHandler);
		Port.WriteMSR(Registers.STAR_MSR, Registers.STAR2);
		Port.WriteMSR(Registers.SFMASK_MSR, 0);

		ulong stack = cast(ulong)PageAllocator.AllocPage() + 0x1000;
		Port.WriteMSR(Registers.GSBASE_MSR, stack);

		long addr = cast(ulong)&test;
		asm {
			mov RCX, addr;
			mov RDX, 0x123456;
			sysret;
		}
	}

	void SyscallHandler() {
		asm {
			naked;
			hlt;

			// save regs used by rdmsr
			mov R8, RAX;
			mov R9, RCX;
			mov R10, RDX;

			// zero RAX higher bits, cuz rdmsr doc doesn't mention if it zeros it
			mov RAX, 0;

			// read the CPU stack address to RDX
			mov ECX, Registers.GSBASE_MSR;
			rdmsr;

			//shl RDX, 32;
			or RDX, RAX;

			// restore saved registers and stick new stack addr in R8, old stack addr in R9
			mov RAX, R8;
			mov RCX, R9;

			mov R8, RDX;
			mov RDX, R10;
			mov R9, RSP;

			// set new stack
			mov RSP, R8;

			// save old stack info where we can get it
			push R9;
			push RBP;

			// vars used by syscall
			push RCX;
			push R11;
			push RAX;

			// call dispatcher
			call SyscallDispatcher;

			pop RAX;
			pop R11;
			pop RCX;

			// restore stack foo
			pop RBP;
			pop R9;
			mov RSP, R9;

			sysret;
		}
	}

	extern(C) void SyscallDispatcher(ulong ID, void* ret, void* params) {
		Log.Print("test");
		while (true) {}
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

	__gshared void test() {
		asm {
			naked;
			mov R11, 0x123456;
			cli;
			hlt;
		}
	}