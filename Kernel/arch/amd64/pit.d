/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module arch.amd64.pit;

import arch.amd64.idt;
import arch.amd64.registers;
import io.ioport;


final abstract class PIT {
@safe: nothrow:
	private static __gshared bool m_enabled;
	private static __gshared uint m_freqency;
	private static __gshared size_t m_counter;
	
	private enum Scale = 1193180;
	
    private enum Register {
        A       = 0x40,
        B       = 0x41,
        C       = 0x42,
        Control = 0x43,
        Set     = 0x36
    }

    static void init(uint frequency = 1000) @trusted {
		IDT.register(irq(0), &onTick);
		
		m_freqency = frequency;
        uint divisor = Scale / frequency;

        outPort(Register.Control, Register.Set);
        outPort(Register.A, divisor & 0xFF);
        outPort(Register.A, (divisor >> 8) & 0xFF);
    }
	
	static void earlySleep(size_t amount) @trusted {
		size_t endAt = m_counter + amount;

		while (m_counter < endAt) {
			asm pure nothrow {
				hlt;
			}
		}
	}

    private static void onTick(Registers* r) @trusted {
        m_counter++;
    }
}
