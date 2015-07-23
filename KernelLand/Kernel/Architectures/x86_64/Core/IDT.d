/**
 * Copyright (c) 2014-2015 Trinix Foundation. All rights reserved.
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
 * http://bit.ly/1wIYh3A and read it before using this file.
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


abstract final class IDT {
	private __gshared IDTBase m_idtBase;
	private __gshared InterruptGateDescriptor[256] m_entries;
	

	static void Initialize() {
		m_idtBase.Limit = (InterruptGateDescriptor.sizeof * m_entries.length) - 1;
		m_idtBase.Base  = cast(ulong)m_entries.ptr;
		
		mixin(GenerateIDT!50);
		
		SetSystemGate(3, &isr3, InterruptStackType.Debug);
        SetInterruptGate(8, &ISRIgnore);

        asm {
            lidt m_idtBase;
            sti;
        }
	}

	static void SetInterruptGate(uint num, void* funcPtr, InterruptStackType ist = InterruptStackType.RegisterStack) {
		SetGate(num, SystemSegmentType.InterruptGate, cast(v_addr)funcPtr, 0, ist);
	}
	
	static void SetSystemGate(uint num, void* funcPtr, InterruptStackType ist = InterruptStackType.RegisterStack) {
        SetGate(num, SystemSegmentType.InterruptGate, cast(v_addr)funcPtr, 3, ist);
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
		with (m_entries[num]) {
			TargetLow  = funcPtr & 0xFFFF;
			Segment    = 0x08;
			ist        = istFlags;
			p          = true;
			dpl        = dplFlags;
			Type       = cast(uint)gateType;
			TargetMid  = (funcPtr >> 16) & 0xFFFF;
			TargetHigh = (funcPtr >> 32);
		}
	}
	
	private static template GenerateIDT(uint numberISRs, uint idx = 0) {
		static if (numberISRs == idx)
			const char[] GenerateIDT = ``;
		else
			const char[] GenerateIDT = `SetInterruptGate(` ~ idx.stringof ~ `, &isr` ~ idx.stringof[0 .. $ - 1] ~ `);` ~ GenerateIDT!(numberISRs, idx + 1);
        //TODO: q{} syntax
	}

	private static template GenerateISR(ulong num, bool needDummyError = true) {
		const char[] GenerateISR = `
			void isr` ~ num.stringof[0 .. $ - 2] ~ `() {
				asm {` ~
					(needDummyError ? `push 0UL;` : ``) ~
					`push ` ~ num.stringof ~ `;` ~
					`jmp ISRCommon;` ~
						`
				}
			}
		`;
		
		//TODO: q{} syntax, naked??
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
            Log(`===> Interrupt -.-"`);
            Log("IRQ = %16x | RIP = %16x", stack.IntNumber, stack.RIP);
            Log("RAX = %16x | RBX = %16x", stack.RAX, stack.RBX);
            Log("RCX = %16x | RDX = %16x", stack.RCX, stack.RDX);
            Log("RDI = %16x | RSI = %16x", stack.RDI, stack.RSI);
            Log("RSP = %16x | RBP = %16x", stack.RSP, stack.RBP);
            Log(" R8 = %16x |  R9 = %16x", stack.R8, stack.R9);
            Log("R10 = %16x | R11 = %16x", stack.R10, stack.R11);
            Log("R12 = %16x | R13 = %16x", stack.R12, stack.R13);
            Log("R14 = %16x | R15 = %16x", stack.R14, stack.R15);
            Log(" CS = %16x |  SS = %16x", stack.CS, stack.SS);
            Log("Flags: %16x", stack.Flags);
			Port.Halt();
		} else if (stack.IntNumber < 32)
			Task.CurrentThread.Fault(stack.IntNumber);
		else
			DeviceManager.Handler(*stack);

		/* We must disable interrupts before sending ACK. Enable it with iretq */
		Port.Cli();
		if (stack.IntNumber >= 32)
			DeviceManager.EOI(cast(int)stack.IntNumber - 32);

		Port.RestoreSSE(Task.CurrentThread.SavedState.SSEInt.Data);
	}

	private static void ISRIgnore() {
		asm {
			naked;
			nop;
			nop;
			nop;
			iretq;
		}
	}
	
	extern(C) private static void ISRCommon() {
		asm {
			naked;
			cli; /* TODO: need this?? */

			/* Save context */
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
			
			/* Call dispatcher */
			mov RDI, RSP;
			call Dispatch;
			
			/* Restore context */
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
			iretq;
		}
	}
}