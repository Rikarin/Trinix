/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module arch.amd64.syscall_handler;

import arch.amd64.msr;
import arch.amd64.idt;
import arch.amd64.registers;


abstract final class SyscallHandler {
@safe: nothrow:
    static void init() {
		// TODO: first fix onSyscall handler (missing registers), then uncoment these
		//MSR.write(MSRRegister.LStar, cast(ulong)&onSyscall);
        //MSR.write(MSRRegister.Star, 0x0013_0008_0000_0000);
        //MSR.write(MSRRegister.FMask, 0x200);
		//MSR.write(MSRRegister.SFMask, 1 << 9);
		
		IDT.register(0x80, &syscallHandler);
    }

    private static void syscallHandler(Registers* stack) {
        //Thread.Current.SavedState.SSESyscall.Save();
        //VirtualMemory.KernelPaging.Install();

       // with (stack)
      //      RAX = ResourceManager.CallResource(R9, R8, RDI, RSI, RDX, RBX, RAX);

      //  Process.Current.PageTable.Install();
      //  Thread.Current.SavedState.SSESyscall.Load();
    }

    extern(C) private static void onSyscall() @trusted {
        asm pure nothrow {
            naked;
            swapgs;
            mov [GS:0], RSP;
            mov RSP, [GS:8];
            swapgs;
            sti;
			
			// TODO: missing some stuff
            
            // Save context
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
            
            // Run dispatcher
            mov RDI, RSP;
            call syscallHandler;
            
            // Restore context
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
            
            cli;
            swapgs;
            mov RSP, [GS:0];
            swapgs;
            sysretq;
        }
    }
}