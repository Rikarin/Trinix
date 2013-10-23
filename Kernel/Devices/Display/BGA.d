module Devices.Display.BGA;

import Architectures.Port;


class BGA {
	static void Init(short resX, short resY) {
		Port.Cli();
		Port.Write!short(0x1CE, 0x00);
		
		short prt = Port.Read!short(0x1CF);
		///if (prt < 0xB0C0 || prt > 0xB0C6)
//			return;

		Port.Write!short(0x1CF, 0xB0C4);
		prt = Port.Read!short(0x1CF);

		/** Disable VBE */
		Port.Write!short(0x1CE, 0x04);
		Port.Write!short(0x1CF, 0x00);

		/** Set X resolution */
		Port.Write!short(0x1CE, 0x01);
		Port.Write!short(0x1CF, resX);

		/** Set Y resolution */
		Port.Write!short(0x1CE, 0x02);
		Port.Write!short(0x1CF, resY);

		/** Set BPP */
		Port.Write!short(0x1CE, 0x03);
		Port.Write!short(0x1CF, 32);

		/** Set Virtual Height */
		Port.Write!short(0x1CE, 0x07);
		Port.Write!short(0x1CF, 0x1000);

		Port.Write!short(0x1CE, 0x04);
		Port.Write!short(0x1CF, 0x41);

		Port.Sti();
	}
}