/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module arch.amd64.registers;


struct Registers {
@safe: nothrow:
align(1):
	ulong r15, r14, r13, r12, r11, r10, r9, r8;
	ulong rbp, rdi, rsi, rdx, rcx, rbx, rax;
	ulong intNumber, errorCode;
	ulong rip, cs, flags, rsp, ss;
	
	ulong cr0() {
		return __get_cr0();
	}
	
	ulong cr2() {
		return __get_cr2();
	}
	
	ulong cr3() {
		return __get_cr3();
	}
	
	ulong cr4() {
		return __get_cr4();
	}
}


private extern(C) extern nothrow @trusted {
	ulong __get_cr0();
	ulong __get_cr2();
	ulong __get_cr3();
	ulong __get_cr4();
}
