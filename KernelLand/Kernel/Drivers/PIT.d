module Drivers.PIT;

import TaskManager;
import Architecture;
import ObjectManager;


//Supnut toto do Time v architectures....
public abstract final class PIT : IStaticModule {
	private __gshared ushort _frequency;
	private __gshared ulong _ticks;
	private __gshared ulong _seconds;

	private enum {
		Frequency = 1193180,
		Channel0  = 0x40,
		Channel1  = 0x41,
		Channel2  = 0x42,
		Command   = 0x43
	}

	@property public static ulong Uptime() {
		return _seconds;
	}

	@property public static ulong Time() {
		return (_seconds * 1000) + (_ticks * 1000 / _frequency);
	}

	static bool Initialize(ushort frequency = 100) {
		_frequency = frequency;
		return true;
	}
	
	static bool Install() {
		uint divisor = cast(uint)Frequency / cast(uint)_frequency;

		Port.Write!byte(Command, 0x36);
		Port.Write!byte(Channel0, divisor & 0xFF);
		Port.Write!byte(Channel0, divisor >> 8);

		DeviceManager.RequestIRQ(&IRQHandler, 0);
		return true;
	}
	
	static bool Uninstall() {
		return false;
	}
	
	static bool Finalize() {
		return false;
	}

	public static void IRQHandler(ref InterruptStack stack) {
		_ticks++;
	
		if (_ticks == _frequency) { //I think this will be in Timer in architectures...
			_ticks = 0;
			_seconds++;
		}

		Task.Scheduler();
	}
}