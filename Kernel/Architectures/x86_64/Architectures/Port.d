module Architectures.Port;

import Architectures.CPU;


class Port {
public:
static:
	T Read(T)(ushort port) {
		T ret;
		asm {
			mov DX, port;
		}

		static if (is(T == byte) || is(T == ubyte)) {
			asm {
				in AL, DX;
				mov ret, AL;
			}
		} else static if (is(T == short) || is(T == ushort)) {
			asm {
				in AX, DX;
				mov ret, AX;
			}
		} else static if (is(T == int) || is(T == uint)) {
			asm {
				in EAX, DX;
				mov ret, EAX;
			}
		}

		return ret;
	}

	void Write(T)(ushort port, int data) {
		asm {
			mov EAX, data;
			mov DX, port;
		}

		static if (is(T == byte) || is(T == ubyte)) {
			asm {
				out DX, AL;
			}
		} else static if (is(T == short) || is(T == ushort)) {
			asm {
				out DX, AX;
			}
		} else static if (is(T == int) || is(T == uint)) {
			asm {
				out DX, EAX;
			}
		}
	}
	
	void EnableFPU() {
		asm {
			mov EAX, CR4;
			or EAX, 0x200;
			mov CR4, EAX;
		}
		
		SetFPUWord(0x37f);
	}

	void SetFPUWord(ushort cw) {
		ushort oldcw;
		ushort oldcw_ptr = cast(ushort)&oldcw;
		
		asm {
			fldcw cw;
			fstcw oldcw_ptr;
		}
	}

	void Cli() {
		asm {
			cli;
		}
	}
	
	void Sti() {
		asm {
			sti;
		}
	}

	void SwapGS() {
		_CPU_swapgs();
	}
	
	void WriteMSR(ulong msr, ulong value) {
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

	ulong ReadMSR(uint msr) {
		uint hi, lo;

		asm {
			mov ECX, msr;
			rdmsr;

			mov hi, EDX;
			mov lo, EAX;
		}

		ulong ret = hi;
		ret <<= 32;
		ret |= lo;

		return ret;
	}
	
	uint cpuidDX(uint func) {
		asm {
			naked;
			mov EAX, EDI;
			cpuid;
			mov EAX, EDX;
			ret;
		}
	}

	uint cpuidAX(uint func) {
		asm {
			naked;
			mov EAX, EDI;
			cpuid;
			ret;
		}
	}
	
	uint cpuidBX(uint func) {
		asm {
			naked;
			mov EAX, EDI;
			cpuid;
			mov EAX, EBX;
			ret;
		}
	}
	
	uint cpuidCX(uint func) {
		asm {
			naked;
			mov EAX, EDI;
			cpuid;
			mov EAX, ECX;
			ret;
		}
	}
	
	uint GetBX() {
		asm {
			naked;
			mov EAX, EBX;
			ret;
		}
	}
	
	uint GetCX() {
		asm {
			naked;
			mov EAX, ECX;
			ret;
		}
	}

	uint GetDX() {
		asm {
			naked;
			mov EAX, EDX;
			ret;
		}
	}
}
