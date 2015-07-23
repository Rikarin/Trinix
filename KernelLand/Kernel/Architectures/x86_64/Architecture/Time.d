/**
 * Copyright (c) 2014-2015 Trinix Foundation. All rights reserved.
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
 * http://bit.ly/1wIYh3A and read it before using this file.
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
		TIMER_RATE        = 14,
		TIMER_FREQUENCY   = 0x8000 >> TIMER_RATE,
		MS_PER_TICK_WHOLE = 1000 / TIMER_FREQUENCY,
		MS_PER_TICK_FRACT = (0x80000000 * (1000 % TIMER_FREQUENCY)) / TIMER_FREQUENCY
	}

	private __gshared ulong m_tscAtLastTick;
	private __gshared ulong m_tscPerTick;

	private __gshared long m_timestamp;
	private __gshared ulong m_ticks;
	private __gshared ulong m_partMiliseconds;
   
    static void Initialize() {
		// Disable NMI
		Port.Write(0x70, Port.Read(0x70) & 0x7F);
		Port.Cli();

		// Set firing rate
		Port.Write(0x70, 0x0A);
		byte val = Port.Read(0x71);
		val &= 0xF0;
		val |= TIMER_RATE + 1;
		Port.Write(0x70, 0x0A);
		Port.Write(0x71, val);

		// Enable IRQ8
		Port.Write(0x70, 0x0B);
		val = Port.Read(0x71);
		Port.Write(0x70, 0x0B);
		Port.Write(0x71, val | 0x40);

		Port.Sti();
		Port.Write(0x70, Port.Read(0x70) | 0x80);

		DeviceManager.RequestIRQ(&IRQHandler, 8);
		Port.Write(0x70, 0x0C);
		cast(void)Port.Read(0x71);
	}

	@property static long Uptime() {
		return m_timestamp;
	}

	@property static long Now() {
		ulong tsc = ReadTSC();
		tsc -= m_tscAtLastTick;
		tsc *= MS_PER_TICK_WHOLE;
		tsc  = m_tscPerTick ? tsc / m_tscPerTick : 0;

		return m_timestamp + tsc;
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
		
		if (m_tscAtLastTick)
			m_tscPerTick = curTSC - m_tscAtLastTick;
		m_tscAtLastTick = curTSC;
		
		m_ticks++;
		m_timestamp += MS_PER_TICK_WHOLE;
		m_partMiliseconds += MS_PER_TICK_FRACT;
		if (m_partMiliseconds > 0x80000000) {
			m_timestamp++;
			
			m_partMiliseconds -= 0x80000000;
		}
		
		//TODO: call timers....

		Task.Scheduler(); //TODO: This isnt good... Time.d is RTC not scheduler

		Port.Write(0x70, 0x0C);
		cast(void)Port.Read(0x71);
	}
}