module Architecture.Time;

import TaskManager;
import Architecture;
import ObjectManager;


public abstract final class Time : IStaticModule {
	private enum MsPerTickWhole = 1000 * (PIT.BaseD * PIT.Divisor) / PIT.BaseN;
	private enum MsPerTickFract = ((0x80000000UL * 1000UL * PIT.BaseD * PIT.Divisor / PIT.BaseN) & 0x7FFFFFFF);

	private enum PIT {
		BaseN = 3579545,
		BaseD = 3,
		Divisor = 11931
	}

	private enum {
		Frequency = 1193180,
		Channel0  = 0x40,
		Channel1  = 0x41,
		Channel2  = 0x42,
		Command   = 0x43
	}

	private __gshared uint _divisor;

	private __gshared ulong _tscAtLastTick;
	private __gshared ulong _tscPerTick;

	private __gshared long _timestamp;
	private __gshared ulong _ticks;
	private __gshared ulong _partMiliseconds;


	static bool Initialize(ushort frequency = 100) {
		_divisor = PIT.Divisor; //cast(uint)Frequency / cast(uint)frequency;
		return true;
	}
	
	static bool Install() {
		//TODO: Use RTC against this shit LOL
		Port.Write!byte(Command, 0x36);
		Port.Write!byte(Channel0, _divisor & 0xFF);
		Port.Write!byte(Channel0, _divisor >> 8);
				
	 	DeviceManager.RequestIRQ(&IRQHandler, 0);
		return true;
	}

	@property public static long Uptime() {
		return _timestamp;
	}

	@property public static long Now() {
		ulong tsc = ReadTSC();
		tsc -= _tscAtLastTick;
		tsc *= MsPerTickWhole;

		if (_tscPerTick)
			tsc /= _tscPerTick;
		else
			tsc = 0;

		return _timestamp + tsc;
	}

	private static ulong ReadTSC() {
		uint a, d;
		
		asm {
			"rdtsc" : "=a" (a), "=d" (d);
		}
		
		return (cast(ulong)d << 32) | a;
	}

	private static void IRQHandler(ref InterruptStack stack) {
		ulong curTSC = ReadTSC();
		
		if (_tscAtLastTick)
			_tscPerTick = curTSC - _tscAtLastTick;
		_tscAtLastTick = curTSC;
		
		_ticks++;
		_timestamp += MsPerTickWhole;
		_partMiliseconds += MsPerTickFract;
		if (_partMiliseconds > 0x80000000) {
			_timestamp++;
			
			_partMiliseconds -= 0x80000000;
		}
		
		//TODO: call timers....

		Task.Scheduler(); //TODO: This isnt good... Time.d is RTC not scheduler
	}
}