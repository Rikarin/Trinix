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
		T ret;

		static if (isByte!T) {
			asm { "inb AL, %1" : "=a"(ret) : "dN"(port); }
		} else static if (isShort!T) {
			asm { "inw AX, %1" : "=a"(ret) : "dN"(port); }
		} else static if (isInt!T) {
			asm { "inl EAX, %1" : "=a"(ret) : "dN"(port); }
		}
		
		return ret;
	}
	
	static void Write(T = byte)(ushort port, int data) pure {
		static if (isByte!T) {
			asm { "outb %0, AL" : : "dN"(port), "a"(data); }
		} else static if (isShort!T) {
			asm { "outw %0, AX" : : "dN"(port), "a"(data); }
		} else static if (isInt!T) {
			asm { "outl %0, EAX" : : "dN"(port), "a"(data); }
		}
	}

	static void Cli() pure {
		asm { "cli"; }
	}
	
	static void Sti() pure {
		asm { "sti"; }
	}

	static void Halt() pure {
		asm { "hlt"; }
	}
	
	static void SwapGS() {
		asm { "swapgs"; }
	}

	static bool GetIntFlag() {
		ulong flags;
		asm {
			"pushfq";
			"pop RAX" : "=a"(flags);
		}

		return (flags & 0x200) == 0x200;
	}

	static void WriteMSR(ulong msr, ulong value) {
		ulong hi, lo;
		lo = value & 0xFFFFFFFF;
		hi = value >> 32UL;
		
		asm { "wrmsr" : : "d"(hi), "a"(lo), "c"(msr); }
	}

	static ulong ReadMSR(uint msr) {
		uint hi, lo;
		
		asm { "rdmsr" : "=d"(hi), "=a"(lo) : "c"(msr); }
		
		ulong ret = hi;
		ret <<= 32;
		ret |= lo;
		
		return ret;
	}
	
	static uint cpuidAX(uint func) {
		asm { "cpuid" : "+a"(func); }
		return func;
	}
	
	static uint cpuidBX(uint func) {
		asm { "cpuid" : "=b"(func) : "a"(func); }
		return func;
	}
	
	static uint cpuidCX(uint func) {
		asm { "cpuid" : "=c"(func) : "a"(func); }
		return func;
	}
	
	static uint cpuidDX(uint func) {
		asm { "cpuid" : "=d"(func) : "a"(func); }
		return func;
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