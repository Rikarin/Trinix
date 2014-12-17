/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module Architectures.x86_64.Core.IDT;

import Core;
import Library;
import TaskManager;
import Architecture;
import ObjectManager;
import MemoryManager;
import SyscallManager;
import Architectures.x86_64.Core;


enum InterruptStackType : ushort {
	RegisterStack,
	StackFault,
	DoubleFault,
	NMI,
	Debug,
	MCE
}

enum InterruptType : uint {
	DivisionByZero,
	Debug,
	NMI,
	Breakpoint,
	INTO,
	OutOfBounds,
	InvalidOpcode,
	NoCoprocessor,
	DoubleFault,
	CoprocessorSegmentOverrun,
	BadTSS,
	SegmentNotPresent,
	StackFault,
	GeneralProtectionFault,
	PageFault,
	UnknownInterrupt,
	CoprocessorFault,
	AlignmentCheck,
	MachineCheck,
}


abstract final class IDT {
	private __gshared IDTBase _idtBase;
	private __gshared InterruptGateDescriptor[256] _entries;
	

	static bool Initialize() {
		_idtBase.Limit = (InterruptGateDescriptor.sizeof * _entries.length) - 1;
		_idtBase.Base = cast(ulong)_entries.ptr;
		
		mixin(GenerateIDT!50);
		
		SetSystemGate(3, &isr3, InterruptStackType.Debug);
		SetInterruptGate(8, &IsrIgnore);

        asm {
            lidt _idtBase;
            sti;
        }
		return true;
	}

	static void SetInterruptGate(uint num, void* funcPtr, InterruptStackType ist = InterruptStackType.RegisterStack) {
		SetGate(num, SystemSegmentType.InterruptGate, cast(ulong)funcPtr, 0, ist);
	}
	
	static void SetSystemGate(uint num, void* funcPtr, InterruptStackType ist = InterruptStackType.RegisterStack) {
		SetGate(num, SystemSegmentType.InterruptGate, cast(ulong)funcPtr, 3, ist);
	}

	private struct IDTBase {
	align(1):
		ushort	Limit;
		ulong	Base;
	}
	
	private struct InterruptGateDescriptor {
	align(1):
		ushort TargetLow;
		ushort Segment;
		private ushort _flags;
		ushort TargetMid;
		uint TargetHigh;
		private uint _reserved;
		
		mixin(Bitfield!(_flags, "ist", 3, "Zero0", 5, "Type", 4, "Zero1", 1, "dpl", 2, "p", 1));
	}
	
	private static void SetGate(uint num, SystemSegmentType gateType, ulong funcPtr, ushort dplFlags, ushort istFlags) {
		with (_entries[num]) {
			TargetLow = funcPtr & 0xFFFF;
			Segment = 0x08;
			ist = istFlags;
			p = true;
			dpl = dplFlags;
			Type = cast(uint)gateType;
			TargetMid = (funcPtr >> 16) & 0xFFFF;
			TargetHigh = (funcPtr >> 32);
		}
	}
	
	private static template GenerateIDT(uint numberISRs, uint idx = 0) {
		static if (numberISRs == idx)
			const char[] GenerateIDT = ``;
		else
			const char[] GenerateIDT = `SetInterruptGate(` ~ idx.stringof ~ `, &isr` ~ idx.stringof[0 .. $ - 1] ~ `);` ~ GenerateIDT!(numberISRs, idx + 1);
	}

	private static template GenerateISR(ulong num, bool needDummyError = true) {
		const char[] GenerateISR = `private static void isr` ~ num.stringof[0 .. $ - 2] ~ `(){asm{naked;` ~
			(needDummyError ? `push 0UL;` : ``) ~ `push ` ~ num.stringof ~ `;jmp IsrCommon;}}`;
	}

	private static template GenerateISRs(uint start, uint end, bool needDummyError = true) {
		static if (start > end)
			const char[] GenerateISRs = ``;
		else
			const char[] GenerateISRs = GenerateISR!(start, needDummyError)
			~ GenerateISRs!(start + 1, end, needDummyError);
	}

	mixin(GenerateISR!0);
	mixin(GenerateISR!1);
	mixin(GenerateISR!2);
	mixin(GenerateISR!3);
	mixin(GenerateISR!4);
	mixin(GenerateISR!5);
	mixin(GenerateISR!6);
	mixin(GenerateISR!7);
	mixin(GenerateISR!(8, false));
	mixin(GenerateISR!9);
	mixin(GenerateISR!(10, false));
	mixin(GenerateISR!(11, false));
	mixin(GenerateISR!(12, false));
	mixin(GenerateISR!(13, false));
	mixin(GenerateISR!(14, false));
	mixin(GenerateISRs!(15, 49));
	
	private static void Dispatch(InterruptStack* stack) {
		Port.SaveSSE(Task.CurrentThread.SavedState.SSEInt.Data);

		if (stack.IntNumber == 0xE)
			Paging.PageFaultHandler(*stack);
		else if (stack.IntNumber == 0xD) {
			Log.WriteJSON("interrupt", "{");
			Log.WriteJSON("irq", stack.IntNumber);
			Log.WriteJSON("rax", stack.RAX);
			Log.WriteJSON("rbx", stack.RBX);
			Log.WriteJSON("rcx", stack.RCX);
			Log.WriteJSON("rdx", stack.RDX);
			Log.WriteJSON("rip", stack.RIP);
			Log.WriteJSON("rbp", stack.RBP);
			Log.WriteJSON("rsp", stack.RSP);
			Log.WriteJSON("cs", stack.CS);
			Log.WriteJSON("ss", stack.SS);
			Log.WriteJSON("}");
			Port.Halt();
		} else if (stack.IntNumber < 32)
			Task.CurrentThread.Fault(stack.IntNumber);
		else
			DeviceManager.Handler(*stack);

		// We must disable interrupts before sending ACK. Enable it with iretq
		Port.Cli();
		if (stack.IntNumber >= 32)
			DeviceManager.EOI(cast(int)stack.IntNumber - 32);

		Port.RestoreSSE(Task.CurrentThread.SavedState.SSEInt.Data);
	}

	private static void IsrIgnore() {
        asm {
            naked;
            nop;
            nop;
            nop;
            jmp _CPU_iretq;
        }
	}
	
	extern(C) private static void IsrCommon() {
		asm {
            naked;
            cli;

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

            // Save data segments
         //   mov AX, DS;
         //   push RAX;
            // Set data registers
         //   mov AX, 0x10;
         //   mov DS, AX;
         //   mov ES, AX;
         //   mov FS, AX;
         //   mov GS, AX;
         //   mov SS, AX;

            // Run dispatcher
            mov RDI, RSP;
            call Dispatch;

            // Restore data segments
        //    pop RAX;
         //   mov DS, AX;
         //   mov ES, AX;
         //   mov FS, AX;
         //   mov GS, AX;

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

            add RSP, 16;
            //jmp _CPU_iretq;
            iretq;
		}
	}
}


/*
	Log.WriteJSON("r15", stack.R15);
	Log.WriteJSON("r14", stack.R14);
	Log.WriteJSON("r13", stack.R13);
	Log.WriteJSON("r12", stack.R12);
	Log.WriteJSON("r11", stack.R11);
	Log.WriteJSON("r10", stack.R10);
	Log.WriteJSON("r9", stack.R9);
	Log.WriteJSON("r8", stack.R8);
	Log.WriteJSON("rbp", stack.RBP);
	Log.WriteJSON("rdi", stack.RDI);
	Log.WriteJSON("rsi", stack.RSI);
	Log.WriteJSON("rdx", stack.RDX);
	Log.WriteJSON("rcx", stack.RCX);
	Log.WriteJSON("rbx", stack.RBX);
	Log.WriteJSON("rax", stack.RAX);
	Log.WriteJSON("int", stack.IntNumber);
	Log.WriteJSON("err", stack.ErrorCode);
	Log.WriteJSON("rip", stack.RIP);
	Log.WriteJSON("cs", stack.CS);
	Log.WriteJSON("flags", stack.Flags);
	Log.WriteJSON("rsp", stack.RSP);
	Log.WriteJSON("ss", stack.SS);
	Port.Halt();
 */