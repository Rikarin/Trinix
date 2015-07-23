/**
 * Copyright (c) 2014-2015 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 1.0 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * https://github.com/Bloodmanovski/Trinix and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module Architecture.Port;

import Library;

private extern(C) extern pure nothrow {
    void _Proc_EnableSSE();
    void _Proc_DisableSSE();
    void _Proc_InitialiseSSE();
    void _Proc_SaveSSE(ulong ptr);
    void _Proc_RestoreSSE(ulong ptr);
}


abstract final class Port {
nothrow:
    static T Read(T = byte)(ushort port) pure {
        asm {
            mov DX, port;
        }

        static if (isByte!T) {
            asm {
                in AL, DX;
                ret;
            }
        } else static if (isShort!T) {
            asm {
                in AX, DX;
                ret;
            }
        } else static if (isInt!T) {
            asm {
                in EAX, DX;
                ret;
            }
        }
    }
    
    static void Write(T = byte)(ushort port, int data) pure {
        asm {
            mov EAX, data;
            mov DX, port;
        }
        
        static if (isByte!T) {
            asm {
                out DX, AL;
            }
        } else static if (isShort!T) {
            asm {
                out DX, AX;
            }
        } else static if (isInt!T) {
            asm {
                out DX, EAX;
            }
        }
    }

    static void Cli() pure {
        asm {
            cli;
        }
    }
    
    static void Sti() pure {
        asm {
            sti;
        }
    }

    static void Halt() pure {
        asm {
            hlt;
        }
    }
    
    static void SwapGS() {
        asm {
            swapgs;
        }
    }

    static bool GetIntFlag() {
        ulong flags;
        asm {
            pushfq;
            pop flags;
        }

        return (flags & 0x200) == 0x200;
    }

    static void WriteMSR(ulong msr, ulong value) {
        ulong hi, lo;
        lo = value & 0xFFFFFFFF;
        hi = value >> 32UL;
        
        asm {
            mov RDX, hi;
            mov RAX, lo;
            mov RCX, msr;
            wrmsr;
        }
    }

    static ulong ReadMSR(uint msr) {
        uint hi, lo;
        
        asm {
            mov RCX, msr;
            rdmsr;
            mov lo, RAX;
            mov hi, RDX;
        }
        
        ulong ret = hi;
        ret <<= 32;
        ret |= lo;
        
        return ret;
    }
    
    static uint cpuidAX(uint func) {
        asm {
            naked;
            mov EAX, EDI;
            cpuid;
            ret;
        }
    }
    
    static uint cpuidBX(uint func) {
        asm {
            naked;
            mov EAX, EDI;
            cpuid;
            mov EAX, EBX;
            ret;
        }
    }
    
    static uint cpuidCX(uint func) {
        asm {
            naked;
            mov EAX, EDI;
            cpuid;
            mov EAX, ECX;
            ret;
        }
    }
    
    static uint cpuidDX(uint func) {
        asm {
            naked;
            mov EAX, EDI;
            cpuid;
            mov EAX, EDX;
            ret;
        }
    }

    static void EnableSSE() pure {
        _Proc_EnableSSE();
    }

    static void DisableSSE() pure {
        _Proc_DisableSSE();
    }

    static void InitializeSSE() {
        _Proc_InitialiseSSE();
    }

    static void SaveSSE(ulong ptr) {
        _Proc_SaveSSE(ptr);
    }

    static void RestoreSSE(ulong ptr) {
        _Proc_RestoreSSE(ptr);
    }
}