module Drivers.Input.Mouse.PS2Mouse;

import Core;
import Drivers;
import VFSManager;
import Architectures;

import System.Threading;


class PS2Mouse : DeviceProto {
private:
	PipeNode pipe;


	enum Bits {
		PORT   = 0x60,
		STATUS = 0x64,
		ABIT   = 0x02,
		BBIT   = 0x01,
		WRITE  = 0xD4,
		F_BIT  = 0x20,
		V_BIT  = 0x08
	}

	struct Packet {
		uint Magic;
		ubyte X;
		ubyte Y;
		ubyte Buttons;
	}


	void Wait(byte type) {
	    foreach (i; 0 .. 100000) {
	        if ((Port.Read!byte(Bits.STATUS) & (type ? Bits.ABIT : Bits.BBIT)) == (type ? 0 : 1))
	            return;
	    }
	}

	void Write(int value) {
    	Wait(1);
    	Port.Write!ubyte(Bits.STATUS, Bits.WRITE);
    	Wait(1);
    	Port.Write!ubyte(Bits.PORT, value);
	}

	byte Read() {
    	Wait(0);
    	return Port.Read!ubyte(Bits.PORT);
	}

public:
	this() {
		Port.Cli();
		Wait(1);
		Port.Write!ubyte(Bits.STATUS, 0xA8);
		Wait(1);
		Port.Write!ubyte(Bits.STATUS, 0x20);
		Wait(0);
		byte status = Port.Read!ubyte(Bits.PORT) | 2;
		Wait(1);
		Port.Write!ubyte(Bits.STATUS, 0x60);
		Wait(1);
		Port.Write!ubyte(Bits.PORT, status);
		Write(0xF6);
		Read();
		Write(0xF4);
		Read();
		Port.Sti();

		PIC.EOI(12);
		LocalAPIC.EOI();
		IOAPIC.UnmaskIRQ(12, 0);
		PIC.EOI(12);
		LocalAPIC.EOI();

		pipe = VFS.CreatePipe("mouse", DeviceManager.DevFS, 0x1C00);
		DeviceManager.RequestIRQ(this, 12);
		DeviceManager.RegisterDevice(this, DeviceInfo("Standard PS2 mouse", DeviceType.Mouse));
	}

	override void IRQHandler(ref InterruptStack r) {
		byte[3] mbyte;
		byte pointer;

		byte status;
		do {
			status = Port.Read!ubyte(Bits.STATUS);
			byte mouseIn = Port.Read!ubyte(Bits.PORT);
			if (status & Bits.F_BIT) {
				final switch (pointer) {
					case 0:
						mbyte[pointer++] = mouseIn;
						if (!(mouseIn & Bits.V_BIT))
							return;
						break;
					case 1:
						mbyte[pointer++] = mouseIn;
						break;
					case 2:
						mbyte[2] = mouseIn;

						if (mbyte[0] & 0x80 || mbyte[0] & 0x40)
							break;

						Packet packet;
						packet.Magic = 0xFEED1234;
						packet.Buttons = mbyte[0];
						packet.X = mbyte[1];
						packet.Y = mbyte[2];

						byte[7] bitbucket = (cast(byte *)&packet)[0 .. 7];
						pipe.Write(0, bitbucket);
						break;
				}
			}
		} while (status & Bits.BBIT);

		PIC.EOI(12);
		LocalAPIC.EOI();
	}
}