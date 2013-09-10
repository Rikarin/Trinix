module Architectures.x86_64.Core.IDT;

import Core.DeviceManager;
import System.Collections.All;
import Architectures.CPU;
import Architectures.Core;
import Architectures.Port;
import Architectures.x86_64.Core.Descriptor;


struct InterruptStack {
align(1):
	ulong R15, R14, R13, R12, R11, R10, R9, R8;
	ulong RBP, RDI, RSI, RDX, RCX, RBX, RAX;
	ulong IntNumber, ErrorCode;
	ulong RIP, CS, Flags, RSP, SS;
}


class IDT {
public:
static:
	alias void delegate(InterruptStack *) InterruptHandler;
	
	enum StackType : ushort {
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
	
	bool Init() {
		idtBase.Limit = (InterruptGateDescriptor.sizeof * entries.length) - 1;
		idtBase.Base = cast(ulong)entries.ptr;
		
		mixin(GenerateIDT!(40));
		
		//SetSystemGate(3, &isr3, StackType.Debug);
		//SetInterruptGate(8, &isrIgnore);
		return true;
	}
	
	bool Install() {
		asm {
			lidt [idtBase];
		}
		return true;
	}
	
	void SetInterruptGate(uint num, void* funcPtr, ushort ist = StackType.RegisterStack) {
		SetGate(num, SystemSegmentType.InterruptGate, cast(ulong)funcPtr, 0, ist);
	}

	void SetSystemGate(uint num, void* funcPtr, ushort ist = StackType.RegisterStack) {
		SetGate(num, SystemSegmentType.InterruptGate, cast(ulong)funcPtr, 3, ist);
	}
	
	
private:
	__gshared IDTBase idtBase;
	__gshared InterruptGateDescriptor[256] entries;
	
	
	struct IDTBase {
	align(1):
		ushort	Limit;
		ulong	Base;
	}

	struct InterruptGateDescriptor {
	align(1):
		ushort TargetLo;
		ushort Segment;
		ushort Flags;
		ushort TargetMid;
		uint   TargetHi;
		uint   Reserved;

		mixin(Bitfield!(Flags, "ist", 3, "Zero0", 5, "Type", 4, "Zero1", 1, "dpl", 2, "p", 1));
	}
	
	void SetGate(uint num, SystemSegmentType gateType, ulong funcPtr, ushort dplFlags, ushort istFlags) {
		with (entries[num]) {
			TargetLo = funcPtr & 0xFFFF;
			Segment = 0x08;
			ist = istFlags;
			p = 1;
			dpl = dplFlags;
			Type = cast(uint)gateType;
			TargetMid = (funcPtr >> 16) & 0xFFFF;
			TargetHi = (funcPtr >> 32);
		}
	}
	
	template GenerateIDT(uint numberISRs, uint idx = 0) {
		static if (numberISRs == idx) 
			const char[] GenerateIDT = ``;
		else
			const char[] GenerateIDT = `
				SetInterruptGate(` ~ idx.stringof ~ `, &isr` ~ idx.stringof[0 .. $ - 1] ~ `);
			` ~ GenerateIDT!(numberISRs, idx + 1);
	}
	
	template GenerateISR(ulong num, bool needDummyError = true) {
		const char[] GenerateISR = `
			void isr` ~ num.stringof[0 .. $ - 2] ~ `() {
				asm {
					naked; ` ~
					(needDummyError ? `push 0UL;` : ``) ~
					`push ` ~ num.stringof ~ `;` ~
					`jmp isr_common;` ~
						`
				}
			}
		`;
	}

	template GenerateISRs(uint start, uint end, bool needDummyError = true) {
		static if (start > end)
			const char[] GenerateISRs = ``;
		else
			const char[] GenerateISRs = GenerateISR!(start, needDummyError)
				~ GenerateISRs!(start + 1, end, needDummyError);
	}

	mixin(GenerateISR!(0));
	mixin(GenerateISR!(1));
	mixin(GenerateISR!(2));
	mixin(GenerateISR!(3));
	mixin(GenerateISR!(4));
	mixin(GenerateISR!(5));
	mixin(GenerateISR!(6));
	mixin(GenerateISR!(7));
	mixin(GenerateISR!(8, false));
	mixin(GenerateISR!(9));
	mixin(GenerateISR!(10, false));
	mixin(GenerateISR!(11, false));
	mixin(GenerateISR!(12, false));
	mixin(GenerateISR!(13, false));
	mixin(GenerateISR!(14, false));
	mixin(GenerateISRs!(15, 39));
	
	void Dispatch(InterruptStack* stack) {
		debug (only) {
			if (stack.IntNumber != 32) {
				import Core.Log;
				import System.Convert;
				
				Log.PrintSP("\n@irq: " ~ Convert.ToString(stack.IntNumber, 16));
				Log.PrintSP(" @rip: " ~ Convert.ToString(stack.RIP, 16));
				Log.PrintSP(" @cs: " ~ Convert.ToString(stack.CS, 16));
				Log.PrintSP(" @ss: " ~ Convert.ToString(stack.SS, 16));
				if (stack.IntNumber == 0xE || stack.IntNumber == 0xD)
					Log.PrintSP(" @ERR: " ~ Convert.ToString(stack.ErrorCode, 16));
			}
		}

		if (stack.IntNumber < 32) {
		//	asm { cli; hlt; }
		} else if (stack.IntNumber < 48)
			DeviceManager.Handler(*stack);
	}
	
	void isrIgnore() {
		asm {
			naked;
			nop;
			nop;
			nop;
			jmp _CPU_iretq;
		}
	}
	
	extern(C) void isr_common() {
		asm {
			naked;
			// Set data registers
			mov AX, 0x10;
			mov DS, AX;
			mov ES, AX;
			mov FS, AX;
			mov GS, AX;

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
			call Dispatch;

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
			jmp _CPU_iretq;
		}
	}
}
