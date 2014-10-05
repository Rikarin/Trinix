module Drivers.PIC;

import Architecture;
import ObjectManager;



public abstract final class PIC : IStaticModule {
	private enum {
		PIC1 = 0x20,
		PIC2 = 0xA0,
		PIC1Command = PIC1,
		PIC2Command = PIC2,
		PIC1Data = PIC1 + 1,
		PIC2Data = PIC2 + 1
	}

	static bool Initialize() {
		return true;
	}
	
	static bool Install() {
		Port.Write!byte(0x20, 0x11);
		Port.Write!byte(0xA0, 0x11);
		Port.Write!byte(0x21, 0x20);
		Port.Write!byte(0xA1, 0x28);
		Port.Write!byte(0x21, 0x04);
		Port.Write!byte(0xA1, 0x02);
		Port.Write!byte(0x21, 0x01);
		Port.Write!byte(0xA1, 0x01);
		Port.Write!byte(0x21, 0x00);
		Port.Write!byte(0xA1, 0x00);

		return true;
	}

}