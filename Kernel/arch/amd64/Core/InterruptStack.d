/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

 module Architectures.x86_64.Core.InterruptStack;

 struct InterruptStack {
 align(1):
     ulong R15, R14, R13, R12, R11, R10, R9, R8;
     ulong RBP, RDI, RSI, RDX, RCX, RBX, RAX;
     ulong IntNumber, ErrorCode;
     ulong RIP, CS, Flags, RSP, SS;
 }

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
     MachineCheck
 }
