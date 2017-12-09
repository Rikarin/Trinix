/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module Architecture.MSR;


enum MSRRegister : uint {
	ApicBase = 0x1B,
	Efer     = 0xC0000080,
	Star     = 0xC0000081,
	LStar    = 0xC0000082,
	CStar    = 0xC0000083,
	SFMask   = 0xC0000084,
	FSBase   = 0xC0000100,
	GSBase   = 0xC0000101
}


abstract final class MSR {
    static void write(MSRRegister register, ulong value) {
        ulong hi, lo;
        lo = value & 0xFFFFFFFF;
        hi = value >> 32UL;

        asm {
            mov RDX, hi;
            mov RAX, lo;
            mov RCX, register;
            wrmsr;
        }
    }

    static ulong read(MSRRegister register) {
        uint hi, lo;

        asm {
            mov RCX, register;
            rdmsr;
            mov lo, RAX;
            mov hi, RDX;
        }

        ulong ret = hi;
        ret <<= 32;
        ret |= lo;

        return ret;
    }
}
