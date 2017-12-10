/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module io.vga;

import io.ioport;
import common.text;


final abstract class VGA {
static:
@safe: nothrow: @nogc:
	private static __gshared VideoSlot[80 * 25]* m_screen;
	private static __gshared ubyte m_x;
	private static __gshared ubyte m_y;
	private static __gshared SlotColor m_color;
	private static __gshared int m_blockCursor;

	void init() {
		m__screen = cast(VideoSlot[80 * 25] *)0xB8000;
		m_color   = SlotColor(CGAColor.Yellow, CGAColor.Black);
	}
	
	SlotColor color() {
		return m_color;
	}

	void color(SlotColor color) {
		m_color = color;
	}
	
	void clear() @trusted {
		foreach (ref x; *m_screen) {
			x = CGAVideoSlot('\x02', m_color);
		}
		
		m_x = 0;
		m_y = 0;
		moveCursor();
	}

	void writeln(Args...)(Args args) {
		write(args, "\n");
	}

	void write(Args...)(Args args) {
		foreach (arg; args) {
			alias T = Unqual!(typeof(arg));
			
			static if (is(T : const char[])) {
				internalWrite(arg);
			} else static if (is(T == BinaryInt)) {
				internalWrite("0b");
				internalWriteNumber(arg.number, 2);
			} else static if (is(T == HexInt)) {
				internalWrite("0x");
				internalWriteNumber(arg.number, 16);
			} else static if (is(T : V*, V)) {
				internalWritePointer(cast(ulong)arg);
			} else static if (is(T == VAddr) || is(T == PAddr) || is(T == PAddr32)) {
				internalWritePointer(arg.num);
			} else static if (is(T == enum)) {
				//internalWriteEnum(arg);
			} else static if (is(T == bool)) {
				internalWrite((arg) ? "true" : "false");
			} else static if (is(T : char)) {
				internalWrite(arg);
			} else static if (isNumber!T) {
				internalWriteNumber(arg, 10);
			} else static if (isFloating!T) {
				internalWriteFloating(cast(double)arg, 10);
			} else {
				internalWrite(arg.toString);
			}
		}

		moveCursor();
	}
	
	private void moveCursor() {
		if (m_blockCursor > 0) {
			return;
		}
		
		ushort pos = m_y * 80 + m_x;
		outPort!ubyte(0x3D4, 14);
		outPort!ubyte(0x3D5, pos >> 8);
		outPort!ubyte(0x3D4, 15);
		outPort!ubyte(0x3D5, cast(ubyte)pos);
	}

	private void internalWrite(char ch) {
		if (ch == '\n') {
			m_y++;
			m_x = 0;
		} else if (ch == '\r') {
			m_x = 0;
		} else if (ch == '\b') {
			if (m_x)
				m_x--;
		} else if (ch == '\t') {
			uint goal = (m_x + 8) & ~7;
			
			for (; m_x < goal; m_x++) {
				(*m_screen)[m_y * 80 + m_x] = VideoSlot(' ', m_color);
			}
			
			if (m_x >= 80) {
				m_y++;
				m_x %= 80;
			}
		} else {
			(*m_screen)[m_y * 80 + m_x] = VideoSlot(ch, m_color);
			m_x++;

			if (m_x >= 80) {
				m_y++;
				m_x = 0;
			}
		}

		if (m_y >= 25) {
			for (int yy = 0; yy < 25 - 1; yy++) {
				for (int xx = 0; xx < 80; xx++) {
					(*_screen)[yy * 80 + xx] = (*m_screen)[(yy + 1) * 80 + xx];
				}
			}

			m_y--;
			for (int xx = 0; xx < 80; xx++) {
				auto slot = &(*m_screen)[m_y * 80 + xx];
				slot.ch = ' ';
				slot.color = SlotColor(CGAColor.Cyan, CGAColor.Black); //XXX: Stupid hack to fix colors while scrolling
			}
		}

		moveCursor();
	}
	
	private void internalWrite(in char[] str) {
		foreach (char ch; str) {
			internalWrite(ch);
		}
	}

	private void internalWrite(char* str) @trusted {
		while (*str) {
			internalWrite(*(str++));
		}
	}

	private void internalWriteNumber(S = long)(S value, uint base) { // TODO if
		char[S.sizeof * 8] buf;
		internalWrite(itoa(value, buf, base));
	}

	private void internalWritePointer(ulong value) {
		char[ulong.sizeof * 8] buf;
		string val = itoa(value, buf, 16, 16);
		
		internalWrite("0x");
		internalWrite(val[0 .. 8]);
		internalWrite('_');
		internalWrite(val[8 .. 16]);
	}

	private void internalWriteFloating(double value, uint base) {
		char[double.sizeof * 8] buf;
		internalWrite(dtoa(value, buf, base));
	}
}


enum CGAColor {
	Black        = 0,
	Blue         = 1,
	Green        = 2,
	Cyan         = 3,
	Red          = 4,
	Magenta      = 5,
	Brown        = 6,
	LightGrey    = 7,
	DarkGrey     = 8,
	LightBlue    = 9,
	LightGreen   = 10,
	LightCyan    = 11,
	LightRed     = 12,
	LightMagenta = 13,
	Yellow       = 14,
	White        = 15
}

private struct SlotColor {
@safe: nothrow: pure: @nogc:
	private ubyte m_color;

	this(CGAColor fg, CGAColor bg) {
		m_color = ((bg & 0xF) << 4) | (fg & 0xF);
	}

	CGAColor foreground() {
		return cast(CGAColor)(m_color & 0xF);
	}

	CGAColor foreground(CGAColor c) {
		m_color = (m_color & 0xF0) | (c & 0xF);
		return cast(CGAColor)(m_color & 0xF);
	}

	CGAColor background() {
		return cast(CGAColor)((m_color >> 4) & 0xF);
	}

	CGAColor background(CGAColor c) {
		m_color = ((c & 0xF) << 4) | (m_color & 0xF);
		return cast(CGAColor)((m_color >> 4) & 0xF);
	}
}

private struct VideoSlot {
	char ch;
	SlotColor color;
}
