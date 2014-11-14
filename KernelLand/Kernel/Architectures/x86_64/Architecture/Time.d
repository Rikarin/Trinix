module Architecture.Time;


public abstract final class Time { //TODO
	private __gshared ulong _tscAtLastTick;
	private __gshared ulong _tscPerTick;

	private __gshared long _timestamp;
	private __gshared ulong _ticks;
	private __gshared ulong _partMiliseconds;


	public void UpdateTimestamp() {
		ulong curTSC = ReadTSC();

		if (_tscAtLastTick)
			_tscPerTick = curTSC - _tscAtLastTick;
		_tscAtLastTick = curTSC;

		_ticks++;
		_timestamp += 0;

		//call timers....
	}

	private static ulong ReadTSC() {
		uint a, d;

		asm {
			"rdtsc";
			"mov %0, EDX" : "=r"(d);
			"mov %0, EAX" : "=r"(a);
		}

		return (cast(ulong)d << 32) | a;
	}
}