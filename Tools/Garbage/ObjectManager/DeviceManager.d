/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module ObjectManager.DeviceManager;

import VFSManager;
import Architecture;


struct InterruptStack {
align(1):
    ulong R15, R14, R13, R12, R11, R10, R9, R8;
    ulong RBP, RDI, RSI, RDX, RCX, RBX, RAX;
    ulong IntNumber, ErrorCode;
    ulong RIP, CS, Flags, RSP, SS;
}

/* TODO: move this to the framework */
enum DeviceType {
    Null,
    Misc,
    Terminal,
    Video,
    Audio,
    Disk,
    Task,
    IPC,
    Input,
    Network,
    FileSystem
}


abstract final class DeviceManager {
    private __gshared void function(ref InterruptStack stack) m_handlers[48];
    __gshared DirectoryNode DevFS;

    static void RequestIRQ(void function(ref InterruptStack) handle, int intNumber) {
        if (intNumber < 16)
            m_handlers[intNumber + 32] = handle;
    }

    static void RequestISR(void function(ref InterruptStack) handle, int intNumber) {
        if (intNumber < 32)
            m_handlers[intNumber] = handle;
    }

    import Core;
    static void Handler(ref InterruptStack stack) {
        if (stack.IntNumber < 48) {
            if (m_handlers[stack.IntNumber] !is null) {
                m_handlers[stack.IntNumber](stack);
            }
        }
    }

    static void EOI(int irqNumber) {
        if (irqNumber >= 8)
            Port.Write(0xA0, 0x20);
        
        Port.Write(0x20, 0x20);
    }

    static void DumpStack(ref InterruptStack stack) {
        Log(`===> Interrupt -.-"`);
        Log("IRQ = %16x | RIP = %16x", stack.IntNumber, stack.RIP);
        Log("RAX = %16x | RBX = %16x", stack.RAX, stack.RBX);
        Log("RCX = %16x | RDX = %16x", stack.RCX, stack.RDX);
        Log("RDI = %16x | RSI = %16x", stack.RDI, stack.RSI);
        Log("RSP = %16x | RBP = %16x", stack.RSP, stack.RBP);
        Log(" R8 = %16x |  R9 = %16x", stack.R8,  stack.R9);
        Log("R10 = %16x | R11 = %16x", stack.R10, stack.R11);
        Log("R12 = %16x | R13 = %16x", stack.R12, stack.R13);
        Log("R14 = %16x | R15 = %16x", stack.R14, stack.R15);
        Log(" CS = %16x |  SS = %16x", stack.CS,  stack.SS);
        Log("Error: %16x", stack.ErrorCode);
        Log("Flags: %16x", stack.Flags);
    }
}