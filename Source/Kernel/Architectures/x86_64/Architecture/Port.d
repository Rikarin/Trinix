module Architecture.Port;

private extern(C) void _Proc_EnableSSE();
private extern(C) void _Proc_DisableSSE();
private extern(C) void _Proc_InitialiseSSE();
private extern(C) void _Proc_SaveSSE(ulong ptr);
private extern(C) void _Proc_RestoreSSE(ulong ptr);


public abstract final class Port {
	public static T Read(T)(ushort port) {
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
	
	public static void Write(T)(ushort port, int data) {
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

	public static void Cli() {
		asm {
			"cli";
		}
	}
	
	public static void Sti() {
		asm {
			"sti";
		}
	}

	public static void Halt() {
		asm {
			"hlt";
		}
	}
	
	public static void SwapGS() {
		asm {
			"swapgs";
		}
	}

	public static bool GetIntFlag() {
		ulong flags;
		asm {
			"pushfq";
			"pop RAX" : "=a"(flags);
		}

		return (flags & 0x200) == 0x200;
	}

	public static void WriteMSR(ulong msr, ulong value) {
		ulong hi, lo;
		lo = value & 0xFFFFFFFF;
		hi = value >> 32UL;
		
		asm {
			"wrmsr" : : "d"(hi), "a"(lo), "c"(msr);
		}
	}

	public static ulong ReadMSR(uint msr) {
		uint hi, lo;
		
		asm {
			"rdmsr" : "=d"(hi), "=a"(lo) : "c"(msr);
		}
		
		ulong ret = hi;
		ret <<= 32;
		ret |= lo;
		
		return ret;
	}
	
	public static uint cpuidAX(uint func) {
		asm {
			"cpuid" : "+a"(func);
		}
		return func;
	}
	
	public static uint cpuidBX(uint func) {
		asm {
			"cpuid" : "=b"(func) : "a"(func);
		}
		return func;
	}
	
	public static uint cpuidCX(uint func) {
		asm {
			"cpuid" : "=c"(func) : "a"(func);
		}
		return func;
	}
	
	public static uint cpuidDX(uint func) {
		asm {
			"cpuid" : "=d"(func) : "a"(func);
		}
		return func;
	}

	public static void EnableSSE() {
		_Proc_EnableSSE();
	}

	public static void DisableSSE() {
		_Proc_DisableSSE();
	}

	public static void InitializeSSE() {
		_Proc_InitialiseSSE();
	}

	public static void SaveSSE(ulong ptr) {
		_Proc_SaveSSE(ptr);
	}

	public static void RestoreSSE(ulong ptr) {
		_Proc_RestoreSSE(ptr);
	}
}