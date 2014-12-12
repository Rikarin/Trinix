module Architecture.Port;

private extern(C) void _Proc_EnableSSE();
private extern(C) void _Proc_DisableSSE();
private extern(C) void _Proc_InitialiseSSE();
private extern(C) void _Proc_SaveSSE(ulong ptr);
private extern(C) void _Proc_RestoreSSE(ulong ptr);


abstract final class Port {
	static T Read(T)(ushort port) {
		T ret;

		static if (is(T == byte) || is(T == ubyte)) {
			asm {
				"inb AL, %1" : "=a"(ret) : "dN"(port);
			}
		} else static if (is(T == short) || is(T == ushort)) {
			asm {
				"inw AX, %1" : "=a"(ret) : "dN"(port);
			}
		} else static if (is(T == int) || is(T == uint)) {
			asm {
				"inl EAX, %1" : "=a"(ret) : "dN"(port);
			}
		}
		
		return ret;
	}
	
	static void Write(T)(ushort port, int data) {
		static if (is(T == byte) || is(T == ubyte)) {
			asm {
				"outb %0, AL" : : "dN"(port), "a"(data);
			}
		} else static if (is(T == short) || is(T == ushort)) {
			asm {
				"outw %0, AX" : : "dN"(port), "a"(data);
			}
		} else static if (is(T == int) || is(T == uint)) {
			asm {
				"outl %0, EAX" : : "dN"(port), "a"(data);
			}
		}
	}

	static void Cli() {
		asm {
			"cli";
		}
	}
	
	static void Sti() {
		asm {
			"sti";
		}
	}

	static void Halt() {
		asm {
			"hlt";
		}
	}
	
	static void SwapGS() {
		asm {
			"swapgs";
		}
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
		
		asm {
			"wrmsr" : : "d"(hi), "a"(lo), "c"(msr);
		}
	}

	static ulong ReadMSR(uint msr) {
		uint hi, lo;
		
		asm {
			"rdmsr" : "=d"(hi), "=a"(lo) : "c"(msr);
		}
		
		ulong ret = hi;
		ret <<= 32;
		ret |= lo;
		
		return ret;
	}
	
	static uint cpuidAX(uint func) {
		asm {
			"cpuid" : "+a"(func);
		}
		return func;
	}
	
	static uint cpuidBX(uint func) {
		asm {
			"cpuid" : "=b"(func) : "a"(func);
		}
		return func;
	}
	
	static uint cpuidCX(uint func) {
		asm {
			"cpuid" : "=c"(func) : "a"(func);
		}
		return func;
	}
	
	static uint cpuidDX(uint func) {
		asm {
			"cpuid" : "=d"(func) : "a"(func);
		}
		return func;
	}

	static void EnableSSE() {
		_Proc_EnableSSE();
	}

	static void DisableSSE() {
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