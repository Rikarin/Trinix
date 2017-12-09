/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module Architecture.IOPort;


T inPort(T = byte)(ushort port) @trusted {
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

void outPort(T = byte)(ushort port, int data) @trusted {
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
