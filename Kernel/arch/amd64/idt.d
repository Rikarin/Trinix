/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module arch.amd64.idt;

import arch.amd64.registers;
import arch.amd64.pic;
import common.bitfield;
import io.ioport;


abstract final class IDT {
static:
@safe: nothrow: @nogc:
	alias InterruptCallback = void function(scope Registers* regs);
	
    private __gshared Base m_base;
    private __gshared Descriptor[256] m_entries;
	private __gshared InterruptCallback[256] m_handlers;
    

    void init() @trusted {
        m_base.limit = Descriptor.sizeof * m_entries.length - 1;
        m_base.base  = cast(ulong)m_entries.ptr;
        
		initISR();
		flush();
		
		register(0x0D, &onGPF);

		asm pure nothrow {
			sti;
		}
    }
	
	void flush() @trusted {
		auto base = &m_base;
	
		asm pure nothrow {
			mov RAX, base;
			lidt [RAX];
		}
	}
	
	void register(uint id, InterruptCallback callback) {
		m_handlers[id] = callback;
	}
	
	VAddr registerGate(uint id, VAddr func) {
		VAddr ret;
		
		with (desc[id]) {
			ret = ((cast(ulong)targetHi << 32UL) | (cast(ulong)targetMid << 16UL) | cast(ulong)targetLo);
		}
			
        setGate(id, SystemSegmentType.InterruptGate, funcPtr, 0, InterruptStackType.RegisterStack);
		return ret;
    }
	
	private void setGate(uint id, SystemSegmentType gateType, ulong funcPtr, ushort dplFlags, ushort istFlags) {
        with (m_entries[num]) {
            targetLo  = funcPtr & 0xFFFF;
            segment   = 0x08;
            ist       = istFlags;
            p         = true;
            dpl       = dplFlags;
            type      = cast(uint)gateType;
            targetMid = (funcPtr >> 16) & 0xFFFF;
            targetHi  = (funcPtr >> 32);
        }
    }
	
	private void initISR() {
		mixin(addRoutines!(0, 255));
		
		setGate(3,      SystemSegmentType.InterruptGate, cast(ulong)&isr3,      3, InterruptStackType.Debug);
		setGate(8,      SystemSegmentType.InterruptGate, cast(ulong)&isrIgnore, 0, InterruptStackType.RegisterStack);
		setGate(irq(1), SystemSegmentType.InterruptGate, cast(ulong)&isrIgnore, 0, InterruptStackType.RegisterStack);
		setGate(irq(4), SystemSegmentType.InterruptGate, cast(ulong)&isrIgnore, 0, InterruptStackType.RegisterStack);
		setGate(0x80,   SystemSegmentType.InterruptGate, cast(ulong)&isr128,    3, InterruptStackType.RegisterStack);
	}
	
	private extern(C) void isrCommon() @trusted {
        asm pure nothrow {
            naked;
            cli;

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
            call isrHandler;
            
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
            db 0x48, 0xCF; // iretq;
        }
    }
	
	private void isrIgnore() @trusted {
        asm pure nothrow {
            naked;
			cli;
            nop;
            nop;
            nop;

            db 0x48, 0xCF; // iretq;
        }
    }
	
	private extern(C) isrHandler(Registers* r) {
		// TODO: save SSE
		r.intNumber &= 0xFF;
		
		if (PIC.isEnabled && irq(0) <= r.intNumber && r.intNumber <= irq(16)) {
			if (r.intNumber >= irq(8)) {
				outPort!ubyte(0xA0, 0x20);
			}
			
			outPort!ubyte(0x20, 0x20);
		}
		
		if (auto x = m_handlers[r.intNumber]) {
			x(r);
		} else {
			// TODO: print unhandled interrupt
		}
		
		// TODO: load SSE
	}
	
	private void onGPF(scope Registers* r) {
		// TODO: print GPF
	
		while (true) {
			asm @trusted pure nothrow {
				hlt;
			}
		}
	}
	
	private template generateRoutine(ulong id, bool hasError = false) {
		enum generateRoutine = `
			private static void isr` ~ id.stringof[0 .. $ - 2] ~ `() @trusted {
				asm pure nothrow {
					naked;
					` ~ (hasError ? "" : "push 0UL;") ~ `
					push ` ~ id.stringof ~ `;
					jmp isrCommon;
				}
			}
		`;
	}

	private template generateRoutines(ulong from, ulong to, bool hasError = false) {
		static if (from <= to)
			enum generateRoutines = generateRoutine!(from, hasError) ~ generateRoutine!(from + 1, to, hasError);
		else
			enum generateRoutines = "";
	}
	
	private template addRoutine(ulong id) {
		enum addRoutine = `
			setGate(` ~ id.stringof[0 .. $ - 2] ~ `, SystemSegmentType.InterruptGate, cast(ulong)&isr`
				~ id.stringof[0 .. $ - 2] ~ `, 0, InterruptStackType.RegisterStack);`;
	}

	private template addRoutines(ulong from, ulong to) {
		static if (from <= to)
			enum addRoutines = addRoutine!from ~ addRoutines!(from + 1, to);
		else
			enum addRoutines = "";
	}
	
	mixin(generateRoutines!(0, 7));
	mixin(generateRoutine!(8, true));
	mixin(generateRoutine!(9));
	mixin(generateRoutines!(10, 14, true));
	mixin(generateRoutines!(15, 255));
}


alias irq = (byte x) => cast(byte)(0x20 + x);

enum InterruptStackType : ushort {
	RegisterStack,
	StackFault,
	DoubleFault,
	NMI,
	Debug,
	MCE
}

enum InterruptType : ubyte {
	DivisionByZero,
	Debug,
	NMI,
	Breakpoint,
	Overflow,
	OutOfBounds,
	InvalidOpcode,
	CoprocessorNotAvailable,
	DoubleFault,
	CoprocessorSegmentOverrun,
	InvalidTaskStateSegment,
	SegmentNotPresent,
	StackFault,
	GeneralProtectionFault,
	PageFault,
	UnknownInterrupt,
	CoprocessorFault,
	AlignmentCheck,
	MachineCheck,
	SimdFloatingPointException
}

enum SystemSegmentType : ubyte {
    LocalDescriptorTable = 0b0010,
    AvailableTSS         = 0b1001,
    BusyTSS              = 0b1011,
    CallGate             = 0b1100,
    InterruptGate        = 0b1110,
    TrapGate             = 0b1111
}


private struct Base {
align(1):
	ushort limit;
	ulong  base;
}

private struct Descriptor {
align(1):
	ushort         targetLo;
	ushort         segment;
	private ushort m_flags;
	ushort         targetMid;
	uint           targetHi;
	private uint   _reserved_0;
	
	mixin(bitfield!(m_flags, "ist", 3, "zero0", 5, "type", 4, "zero1", 1, "dpl", 2, "p", 1));
}

static assert(Base.sizeof == 10);
static assert(Descriptor.sizeof == 16);
