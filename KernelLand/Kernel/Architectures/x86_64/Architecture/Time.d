module Architecture.Time;

import TaskManager;
import Architecture;
import ObjectManager;


public abstract final class Time : IStaticModule {
	private enum {
		TimerRate = 14,
		TimerFreq = 0x8000 >> TimerRate,
		MsPerTickWhole = 1000 / TimerFreq,
		MsPerTickFract = (0x80000000 * (1000 % TimerFreq)) / TimerFreq
	}

	private __gshared ulong _tscAtLastTick;
	private __gshared ulong _tscPerTick;

	private __gshared long _timestamp;
	private __gshared ulong _ticks;
	private __gshared ulong _partMiliseconds;


	static bool Initialize() {
		return true;
	}
	
	static bool Install() {
		// Disable NMI
		Port.Write!byte(0x70, Port.Read!byte(0x70) & 0x7F);
		Port.Cli();

		// Set firing rate
		Port.Write!byte(0x70, 0x0A);
		byte val = Port.Read!byte(0x71);
		val &= 0xF0;
		val |= TimerRate + 1;
		Port.Write!byte(0x70, 0x0A);
		Port.Write!byte(0x71, val);

		// Enable IRQ8
		Port.Write!byte(0x70, 0x0B);
		val = Port.Read!byte(0x71);
		Port.Write!byte(0x70, 0x0B);
		Port.Write!byte(0x71, val | 0x40);

		Port.Sti();
		Port.Write!byte(0x70, Port.Read!byte(0x70) | 0x80);

		DeviceManager.RequestIRQ(&IRQHandler, 8);
		Port.Write!byte(0x70, 0x0C);
		Port.Read!byte(0x71);

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

		Port.Write!byte(0x70, 0x0C);
		Port.Read!byte(0x71);
	}
}