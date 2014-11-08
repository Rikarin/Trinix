module SyscallManager.SyscallHandler;

import Architecture;
import ObjectManager;
import SyscallManager;

private extern(C) void _CPU_syscall_handler();


public abstract final class SyscallHandler : IStaticModule {
	private enum Registers : ulong {
		IA32_STAR    = 0xC000_0081,
		IA32_LSTAR   = 0xC000_0082,
		IA32_FMASK   = 0xC000_0084,
		IA32_FS_BASE = 0xC000_0100,
		IA32_GS_BASE = 0xC000_0101,

		STAR         = 0x0013_0008_0000_0000
	}

	public static bool Initialize() {
		Port.WriteMSR(Registers.IA32_LSTAR, cast(ulong)&_CPU_syscall_handler);
		Port.WriteMSR(Registers.IA32_STAR, Registers.STAR);
		Port.WriteMSR(Registers.IA32_FMASK, 0x600);
		return true;
	}
}

extern(C) void SyscallDispatcher(InterruptStack* stack) {
	import Core;
	Log.WriteLine("tessssssssssssssssssssssssssttttttttt");
	//stack.RAX = ResourceManager.CallResource(stack.RAX, stack.RBX, stack.RCX, stack.RDX, stack.R8, stack.R9, stack.R10);
}