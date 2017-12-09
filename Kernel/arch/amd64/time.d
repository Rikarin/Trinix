/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Architecture.Time;

import Architecture;
import Architectures.x86_64.Core;


final abstract class Time {
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

        //TODO: DeviceManager.RequestIRQ(&IRQHandler, 8);
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
        m_timestamp       += MS_PER_TICK_WHOLE;
        m_partMiliseconds += MS_PER_TICK_FRACT;
        if (m_partMiliseconds > 0x80000000) {
            m_timestamp++;

            m_partMiliseconds -= 0x80000000;
        }

        //TODO: call timers....

        Port.Write(0x70, 0x0C);
        cast(void)Port.Read(0x71);
    }
}
