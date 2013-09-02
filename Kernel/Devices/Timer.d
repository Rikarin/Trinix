module Devices.Timer;

import Architectures.Port;
import DeviceManager.Device;
import Devices.DeviceProto;


class Timer : DeviceProto {
private:
	ubyte frequency;
	ulong seconds;
	ubyte ticks;


public:
	const uint PIT_FREQUENCY = 1193180;	

	const ubyte CHANNEL_0	 = 0x40;
	const ubyte CHANNEL_1	 = 0x41;
	const ubyte CHANNEL_2	 = 0x42;
	const ubyte PIT_CMD		 = 0x43;

	@property ulong Uptime() { return seconds; }

	
	this(ubyte frequency = 100) {
		ticks = 0;
		seconds = 0;

		Device.RegisterDevice(this, DeviceInfo("Timer", DeviceType.System));
		Device.RequestIRQ(this, 0);

		SetFrequency(frequency);
	}

	void SetFrequency(ubyte frequency) {
		this.frequency = frequency;

		uint divisor = PIT_FREQUENCY / frequency;
		Port.Write!(ubyte)(PIT_CMD, 0x36);
		Port.Write!(ubyte)(CHANNEL_2, divisor & 0xFF);
		Port.Write!(ubyte)(CHANNEL_2, divisor >> 8);
	}
	
	override void IRQHandler(ref InterruptStack r) {
		ticks++;
		if (ticks == frequency) {
			ticks = 0;
			seconds++;
		}
	}
}