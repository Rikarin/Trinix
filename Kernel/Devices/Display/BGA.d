module Devices.Display.BGA;

import Architectures.Port;


class BGA {
static:
	enum IOPORT_INDEX = 0x1CE;
	enum IOPORT_DATA  = 0x1CF;


	void Init(short width, short height) {
		Port.Write!short(0x1CE, 0x00);
		ushort prt = Port.Read!short(0x1CF);

		///if (prt < 0xB0C0 || prt > 0xB0C6)
//			return;

		SetVideoMode(width, height, 32, true, true);
	}

	void SetVideoMode(short width, short height, short depth, bool frameBuffer, bool clear) {
		Write(4, 0);
		Write(1, width);
		Write(2, height);
		Write(3, depth);
		Write(4, 1 | (frameBuffer ? 0x40 : 0) | (clear ? 0 : 0x80));
	}

	short Read(short index) {
		Port.Write!short(IOPORT_INDEX, index);
		return Port.Read!short(0x1CF);
	}

	void Write(short index, short value) {
		Port.Write!short(IOPORT_INDEX, index);
		Port.Write!short(IOPORT_DATA, value);
	}
}