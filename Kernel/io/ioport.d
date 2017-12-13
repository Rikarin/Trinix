/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module io.ioport;


T inPort(T = byte)(ushort port) @trusted nothrow {
	T ret;
	asm @safe nothrow @nogc {
		mov DX, port;
	}

	static if (is(T == byte) || is(T == ubyte)) {
		asm @safe nothrow @nogc {
			in AL, DX;
			mov ret, AL;
		}
	} else static if (is(T == short) || is(T == ushort)) {
		asm @safe nothrow @nogc {
			in AX, DX;
			mov ret, AX;
		}
	} else static if (is(T == int) || is(T == uint)) {
		asm @safe nothrow @nogc {
			in EAX, DX;
			mov ret, EAX;
		}
	}

	return ret;
}

void outPort(T = byte)(ushort port, int data) @trusted nothrow {
	asm @safe nothrow @nogc {
		mov EAX, data;
		mov DX, port;
	}

	static if (is(T == byte) || is(T == ubyte)) {
		asm @safe nothrow @nogc {
			out DX, AL;
		}
	} else static if (is(T == short) || is(T == ushort)) {
		asm @safe nothrow @nogc {
			out DX, AX;
		}
	} else static if (is(T == int) || is(T == uint)) {
		asm @safe nothrow @nogc {
			out DX, EAX;
		}
	}
}
