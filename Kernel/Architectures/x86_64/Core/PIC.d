module Architectures.x86_64.Core.PIC;

import Architectures.Port;


class PIC {
public:
static:
	void Disable() {
		Port.Write!(byte)(0xA1, 0xFF);
		Port.Write!(byte)(0x21, 0xFF);
	}

	void Enable() {
		Port.Write!(byte)(0xA1, 0x00);
		Port.Write!(byte)(0x21, 0x00);
	}

	void DisableIRQ(uint irq) {
		if (irq > 7) {
			irq -= 8;
			byte curMask = Port.Read!(byte)(0xA1);
			curMask |= cast(byte)(1 << irq);
			Port.Write!(byte)(0xA1, curMask);
		} else {
			byte curMask = Port.Read!(byte)(0x21);
			curMask |= cast(byte)(1 << irq);
			Port.Write!(byte)(0x21, curMask);
		}
	}

	void EnableIRQ(uint irq) {
		if (irq > 7) {
			irq -= 8;
			byte curMask = Port.Read!(byte)(0xA1);
			curMask &= cast(byte)(~(1 << irq));
			Port.Write!(byte)(0xA1, curMask);
		} else {
			byte curMask = Port.Read!(byte)(0x21);
			curMask &= cast(byte)(~(1 << irq));
			Port.Write!(byte)(0x21, curMask);
		}
	}

	void EOI(uint irq) {
		if (irq > 7)
			Port.Write!(byte)(0xA0, 0x20);
		Port.Write!(byte)(0x20, 0x20);
	}
}