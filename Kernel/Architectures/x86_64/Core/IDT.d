/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Architectures.x86_64.Core.IDT;

import Core;
import Library;
import Architecture;
import MemoryManager;
import Architectures.x86_64.Core;


abstract final class IDT {
    private __gshared IDTBase m_idtBase;
    private __gshared InterruptGateDescriptor[50] m_entries;
    

    static void Initialize() {
        m_idtBase.Limit = (InterruptGateDescriptor.sizeof * m_entries.length) - 1;
        m_idtBase.Base  = cast(ulong)m_entries.ptr;
        
        mixin(GenerateIDT!50);
        
        SetSystemGate(3, &isr3, InterruptStackType.Debug);
        SetInterruptGate(8, &ISRIgnore);

        asm {
            lidt m_idtBase;
        }
    }

    static void SetInterruptGate(uint num, void* funcPtr, InterruptStackType ist = InterruptStackType.RegisterStack) {
        SetGate(num, SystemSegmentType.InterruptGate, cast(v_addr)funcPtr, 0, ist);
    }
    
    static void SetSystemGate(uint num, void* funcPtr, InterruptStackType ist = InterruptStackType.RegisterStack) {
        SetGate(num, SystemSegmentType.InterruptGate, cast(v_addr)funcPtr, 3, ist);
    }

    align(1) private struct IDTBase {
    align(1):
        ushort Limit;
        ulong  Base;
    }
	static assert(IDTBase.sizeof == 10);
    
    align(1) private struct InterruptGateDescriptor {
    align(1):
        ushort         TargetLow;
        ushort         Segment;
        private ushort _flags;
        ushort         TargetMid;
        uint           TargetHigh;
        private uint   _reserved;
        
        mixin(Bitfield!(_flags, "ist", 3, "Zero0", 5, "Type", 4, "Zero1", 1, "dpl", 2, "p", 1));
    }
	static assert(InterruptGateDescriptor.sizeof == 16);
    
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
            private static void isr` ~ num.stringof[0 .. $ - 2] ~ `() {
                asm { naked;` ~
                    (needDummyError ? `push 0UL;` : ``) ~
                    `push ` ~ num.stringof ~ `;` ~
                    `jmp ISRCommon;` ~
                        `
                }
            }
        `;
        
        //TODO: q{} syntax
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
        Thread.Current.SavedState.SSEInt.Save();

        if (stack.IntNumber == 0xE) { //TODO: remove this. chain: IDT.Dispatch > Task.SendInterruptToThread
            Log.Emergency(`===> Spadlo to -.-"`);
            Log(*stack);

            Port.Cli();
            Port.Hlt();
        } else if (stack.IntNumber < 32) {
            if (Thread.Current.ID == 1) {
                DeviceManager.DumpStack(*stack);
                Port.Cli();
                Port.Halt();
            } else
                Thread.Current.Fault(stack.IntNumber);
        } else
            DeviceManager.Handler(*stack);

        /* We must disable interrupts before sending ACK. Enable it with iretq */
        Port.Cli();
        if (stack.IntNumber >= 32)
            DeviceManager.EOI(cast(int)stack.IntNumber - 32);

        Thread.Current.SavedState.SSEInt.Load();
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
            cli; /* pre istotu */

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