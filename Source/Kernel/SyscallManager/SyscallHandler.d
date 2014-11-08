module SyscallManager.SyscallHandler;

import TaskManager;
import Architecture;
import ObjectManager;
import SyscallManager;


public struct SyscallStack {
align(1):
	ulong R15, R14, R13, R12, R11, R10, R9, R8;
	ulong RBP, RDI, RSI, RDX;
	private ulong _RCX;
	ulong RBX, RAX;
}


public abstract final class SyscallHandler : IStaticModule {
	private enum Registers : ulong {
		IA32_STAR    = 0xC000_0081,
		IA32_LSTAR   = 0xC000_0082,
		IA32_CSTAR   = 0xC000_0083,
		IA32_FMASK   = 0xC000_0084,
		IA32_FS_BASE = 0xC000_0100,
		IA32_GS_BASE = 0xC000_0101,

		STAR         = 0x0013_0008_0000_0000
	}

	public static bool Initialize() {
		Port.WriteMSR(Registers.IA32_LSTAR, cast(ulong)&SyscallCommon);
		Port.WriteMSR(Registers.IA32_STAR, Registers.STAR);
		Port.WriteMSR(Registers.IA32_FMASK, 0x200);
		return true;
	}

	public static void SyscallDispatcher(SyscallStack* stack) {
	//	Port.SaveSSE(Task.CurrentThread.SavedState.SSESyscall.Data);

		with (stack)
			ResourceManager.CallResource(R9, R8, RDI, RSI, RDX, RBX, RAX);

	//	Port.RestoreSSE(Task.CurrentThread.SavedState.SSESyscall.Data);
	}

	extern(C) private static void SyscallCommon() {
		asm {
			"pop RBP"; //Naked

			"swapgs";
			"mov [GS:0], RSP";
			"mov RSP, [GS:8]";
			"swapgs";
			"sti";
			
			// Save context
			"push RAX";
			"push RBX";
			"push RCX";
			"push RDX";
			"push RSI";
			"push RDI";
			"push RBP";
			"push R8";
			"push R9";
			"push R10";
			"push R11";
			"push R12";
			"push R13";
			"push R14";
			"push R15";
			
			// Run dispatcher
			"mov RDI, RSP";
			"call %0" : : "r"(&SyscallDispatcher);
			
			// Restore context
			"pop R15";
			"pop R14";
			"pop R13";
			"pop R12";
			"pop R11";
			"pop R10";
			"pop R9";
			"pop R8";
			"pop RBP";
			"pop RDI";
			"pop RSI";
			"pop RDX";
			"pop RCX";
			"pop RBX";
			"pop RAX";

			"cli";
			"swapgs";
			"mov RSP, [GS:0]";
			"swapgs";

			"sysretq";
		}
	}
}