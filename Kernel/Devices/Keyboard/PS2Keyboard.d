module Devices.Keyboard.PS2Keyboard;

import Architectures.Core;
import Architectures.Port;
import Core.DeviceManager;
import Devices.Keyboard.KeyCodes;
import Devices.DeviceProto;
import FileSystem.PipeDev;

import System.Threading.All;


class PS2Keyboard : DeviceProto {
private:
	ubyte keyset;
	PipeDev pipe;


public:
	this() {
		ubyte code, status = Port.Read!ubyte(0x64);
		while ((status & 1) == 1) {
			Port.Read!ubyte(0x60);
			status = Port.Read!ubyte(0x64);
		}

		Port.Write!ubyte(0x60, 0xF2);
		do {
			status = Port.Read!ubyte(0x64);
		} while (!(status & 1));

		while ((status & 1) == 1) {
			code   = Port.Read!ubyte(0x60);
			status = Port.Read!ubyte(0x64);
		}

		if (code == 0x41)
			keyset = 1;
		else {
			Port.Write!ubyte(0x60, 0xF0);
			Port.Write!ubyte(0x60, 0x00);

			do {
				status = Port.Read!ubyte(0x64);
			} while (!(status & 1));


			status = Port.Read!ubyte(0x64);
			while ((status & 1) == 1) {
				code   = Port.Read!ubyte(0x60);
				status = Port.Read!ubyte(0x64);
			}

			if (code == 0x43)
				keyset = 1;
			else if (code == 0x41)
				keyset = 2;
			else if (code == 0x3F)
				keyset = 3;
			else
				keyset = 1;
		}

		PIC.EOI(1);
		LocalAPIC.EOI();
		IOAPIC.UnmaskIRQ(1, 0);
		PIC.EOI(1);
		LocalAPIC.EOI();

		status = Port.Read!ubyte(0x64);
		while ((status & 1) == 1) {
			Port.Read!ubyte(0x60);
			status = Port.Read!ubyte(0x64);
		}
		Port.Write!ubyte(0x60, 0xF4);

		
		pipe = new PipeDev("keyboard", 128);
		DeviceManager.DevFS.AddNode(pipe);

		DeviceManager.RequestIRQ(this, 1);
		DeviceManager.RegisterDevice(this, DeviceInfo("Standard PS2 keyboard", DeviceType.Keyboard));
	}

	override void IRQHandler(ref InterruptStack r) {
        uint makeState;
		bool upState;

		ubyte data = Port.Read!ubyte(0x60);
		if (!data)
			return;

		Key key = Key.Null;

		if (data == 0xE0)
			makeState = 1;
		else {
			if (data & 0x80) {
				data &= 0x7F;
				upState = true;
			}

			if (!makeState) {
				if (keyset == 1)
					key = Set1Translate[data];
				else
					key = Set2Translate[data];
			} else if (makeState == 1) {
				if (keyset == 1)
					key = Set1TranslateExtra[data];
				else
					key = Set2TranslateExtra[data];
			}
		}

		byte[1] tmp;
		tmp[0] = upState ? -key : key;
		pipe.Write(0, tmp);

		PIC.EOI(1);
		LocalAPIC.EOI();
	}

	Key Set1Translate[256] = [
		0x1E: Key.A,
		0x30: Key.B,
		0x2E: Key.C,
		0x20: Key.D,
		0x12: Key.E,
		0x21: Key.F,
		0x22: Key.G,
		0x23: Key.H,
		0x17: Key.I,
		0x24: Key.J,
		0x25: Key.K,
		0x26: Key.L,
		0x32: Key.M,
		0x31: Key.N,
		0x18: Key.O,
		0x19: Key.P,
		0x10: Key.Q,
		0x13: Key.R,
		0x1F: Key.S,
		0x14: Key.T,
		0x16: Key.U,
		0x2F: Key.V,
		0x11: Key.W,
		0x2D: Key.X,
		0x15: Key.Y,
		0x2C: Key.Z,
		0x02: Key.Num1,
		0x03: Key.Num2,
		0x04: Key.Num3,
		0x05: Key.Num4,
		0x06: Key.Num5,
		0x07: Key.Num6,
		0x08: Key.Num7,
		0x09: Key.Num8,
		0x0A: Key.Num9,
		0x0B: Key.Num0,
		0x29: Key.Quote,
		0x0C: Key.Minus,
		0x0D: Key.Equals,
		0x35: Key.Slash,
		0x0E: Key.Backspace,
		0x39: Key.Space,
		0x0F: Key.Tab,
		0x3A: Key.Capslock,
		0x2A: Key.LeftShift,
		0x1D: Key.LeftControl,
		0x38: Key.LeftAlt,
		0x36: Key.RightShift,
		0x1C: Key.Return,
		0x01: Key.Escape,
		0x3B: Key.F1,
		0x3C: Key.F2,
		0x3D: Key.F3,
		0x3E: Key.F4,
		0x3F: Key.F5,
		0x40: Key.F6,
		0x41: Key.F7,
		0x42: Key.F8,
		0x43: Key.F9,
		0x44: Key.F10,
		0x57: Key.F11,
		0x58: Key.F12,
		0x46: Key.ScrollLock,
		0x1A: Key.LeftBracket,
		0x1B: Key.RightBracket,
		0x45: Key.NumLock,
		0x37: Key.KeypadAsterisk,
		0x4A: Key.KeypadMinus,
		0x4E: Key.KeypadPlus,
		0x53: Key.KeypadPeriod,
		0x52: Key.Keypad0,
		0x4F: Key.Keypad1,
		0x50: Key.Keypad2,
		0x51: Key.Keypad3,
		0x4B: Key.Keypad4,
		0x4C: Key.Keypad5,
		0x4D: Key.Keypad6,
		0x47: Key.Keypad7,
		0x48: Key.Keypad8,
		0x49: Key.Keypad9,
		0x27: Key.Semicolon,
		0x28: Key.Apostrophe,
		0x33: Key.Comma,
		0x34: Key.Period,
		0x2B: Key.Backslash
	];

	Key Set1TranslateExtra[256] = [
		0x5B: Key.LeftMeta,
		0x1D: Key.RightControl,
		0x5C: Key.RightMeta,
		0x38: Key.RightAlt,
		0x52: Key.Insert,
		0x47: Key.Home,
		0x49: Key.PageUp,
		0x53: Key.Delete,
		0x4F: Key.End,
		0x51: Key.PageDown,
		0x48: Key.Up,
		0x4B: Key.Left,
		0x50: Key.Down,
		0x4D: Key.Right,
		0x35: Key.KeypadSlash,
		0x1C: Key.KeypadReturn
	];

	Key Set2Translate[256] = [
		0x1C: Key.A,
		0x32: Key.B,
		0x21: Key.C,
		0x23: Key.D,
		0x24: Key.E,
		0x2B: Key.F,
		0x34: Key.G,
		0x33: Key.H,
		0x43: Key.I,
		0x3B: Key.J,
		0x42: Key.K,
		0x4B: Key.L,
		0x3A: Key.M,
		0x31: Key.N,
		0x44: Key.O,
		0x4D: Key.P,
		0x15: Key.Q,
		0x2D: Key.R,
		0x1B: Key.S,
		0x2C: Key.T,
		0x3C: Key.U,
		0x2A: Key.V,
		0x1D: Key.W,
		0x22: Key.X,
		0x35: Key.Y,
		0x1A: Key.Z,
		0x16: Key.Num1,
		0x1e: Key.Num2,
		0x26: Key.Num3,
		0x25: Key.Num4,
		0x2E: Key.Num5,
		0x36: Key.Num6,
		0x3D: Key.Num7,
		0x3E: Key.Num8,
		0x46: Key.Num9,
		0x45: Key.Num0,
		0x0E: Key.Quote,
		0x4E: Key.Minus,
		0x55: Key.Equals,
		0x4A: Key.Slash,
		0x66: Key.Backspace,
		0x29: Key.Space,
		0x0D: Key.Tab,
		0x58: Key.Capslock,
		0x12: Key.LeftShift,
		0x14: Key.LeftControl,
		0x11: Key.LeftAlt,
		0x59: Key.RightShift,
		0x5A: Key.Return,
		0x76: Key.Escape,
		0x05: Key.F1,
		0x06: Key.F2,
		0x04: Key.F3,
		0x0c: Key.F4,
		0x03: Key.F5,
		0x0B: Key.F6,
		0x83: Key.F7,
		0x0A: Key.F8,
		0x01: Key.F9,
		0x09: Key.F10,
		0x78: Key.F11,
		0x07: Key.F12,
		0x7E: Key.ScrollLock,
		0x54: Key.LeftBracket,
		0x5B: Key.RightBracket,
		0x77: Key.NumLock,
		0x7C: Key.KeypadAsterisk,
		0x7B: Key.KeypadMinus,
		0x79: Key.KeypadPlus,
		0x71: Key.KeypadPeriod,
		0x70: Key.Keypad0,
		0x69: Key.Keypad1,
		0x72: Key.Keypad2,
		0x7A: Key.Keypad3,
		0x6B: Key.Keypad4,
		0x73: Key.Keypad5,
		0x74: Key.Keypad6,
		0x6C: Key.Keypad7,
		0x75: Key.Keypad8,
		0x7D: Key.Keypad9,
		0x4C: Key.Semicolon,
		0x52: Key.Apostrophe,
		0x41: Key.Comma,
		0x49: Key.Period,
		0x5D: Key.Backslash
	];

	Key Set2TranslateExtra[256] = [
		0x1F: Key.LeftMeta,
		0x14: Key.RightControl,
		0x27: Key.RightMeta,
		0x11: Key.RightAlt,
		0x70: Key.Insert,
		0x6C: Key.Home,
		0x7D: Key.PageUp,
		0x71: Key.Delete,
		0x69: Key.End,
		0x7A: Key.PageDown,
		0x75: Key.Up,
		0x6B: Key.Left,
		0x72: Key.Down,
		0x74: Key.Right,
		0x4A: Key.KeypadSlash,
		0x5A: Key.KeypadReturn
	];
}