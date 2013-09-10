module Devices.Timer;

import Core.DeviceManager;
import Architectures.Port;
import Architectures.Core;
import Devices.DeviceProto;
import TaskManager.Task;


class Timer : DeviceProto {
private:
	uint frequency;
	uint div;
	ulong seconds = 0;
	ubyte ticks = 0;


public:
	@property ulong Uptime() { return seconds; }

	
	this(uint frequency = 100) {
		//software enable, map spurious interrupt to dummy isr
		LocalAPIC.apicRegisters.SpuriousIntVector = 0xFF | 0x100;
		//map APIC timer to an interrupt, and by that enable it in one-shot mode
		LocalAPIC.apicRegisters.TmrLocalVectorTable = 32;
		//set up divide value to 16
		LocalAPIC.apicRegisters.TmrDivideConfiguration = 0x03;

		//initialize PIT Ch 2 in one-shot mode
		//waiting 1 sec could slow down boot time considerably,
		//so we'll wait 1/100 sec, and multiply the counted ticks
		Port.Write!(ubyte)(0x61, (Port.Read!(ubyte)(0x61) & 0xFD) | 1);
		Port.Write!(ubyte)(0x43, 0xB2);

		Port.Write!(ubyte)(0x42, 0x9B);
		Port.Read!(ubyte)(0x60);
		Port.Write!(ubyte)(0x42, 0x2E);

		//reset PIT one-shot counter (start counting)
		div = Port.Read!(ubyte)(0x61) & 0xFE;
		Port.Write!(ubyte)(0x61, div);
		Port.Write!(ubyte)(0x61, div | 1);
		//reset APIC timer (set counter to -1)
		LocalAPIC.apicRegisters.TmrInitialCount = 0xFFFFFFFF;

		//now wait until PIT counter reaches zero
		while (!(Port.Read!(ubyte)(0x61) & 0x20)) { }

		//stop APIC timer
		LocalAPIC.apicRegisters.TmrLocalVectorTable = 0x10000;

		//now do the math...
		div = ((0xFFFFFFFF - LocalAPIC.apicRegisters.TmrCurrentCount) + 1) * 16 * 100;


		DeviceManager.RegisterDevice(this, DeviceInfo("Timer", DeviceType.System));
		DeviceManager.RequestIRQ(this, 0);
		SetFrequency(frequency);
	}

	void SetFrequency(uint frequency) {
		this.frequency = frequency;
		ubyte tmp = cast(ubyte)(div / frequency / 16);

		//sanity check, now tmp holds appropriate number of ticks, use it as APIC timer counter initializer
		LocalAPIC.apicRegisters.TmrInitialCount = (tmp < 16 ? 16 : tmp) * 0x1000;
		//finally re-enable timer in periodic mode
		LocalAPIC.apicRegisters.TmrLocalVectorTable = 32 | 0x20000;
		//setting divide value register again not needed by the manuals
		//although I have found buggy hardware that required it
		LocalAPIC.apicRegisters.TmrDivideConfiguration = 0x03;
	}
	
	override void IRQHandler(ref InterruptStack r) {
		ticks++;

		if (ticks == frequency) {
			ticks = 0;
			seconds++;
		}

		PIC.EOI(0);
		LocalAPIC.EOI();

		Task.WakeupSleepers((seconds * 1000) + (ticks * 0x1000) / frequency);
		Task.Switch();
	}
}