/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module Architecture.Time;

import TaskManager;
import Architecture;
import ObjectManager;


abstract final class Time {
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

	@property static long Uptime() {
		return _timestamp;
	}

	@property static long Now() {
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
            rdtsc;
            mov a, EAX;
            mov d, EDX;
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