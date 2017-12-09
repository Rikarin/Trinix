/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Architectures.x86_64.Core.PIT;

import Architecture;
import Architectures.x86_64.Core;


final abstract class PIT {
    private enum {
        PIT_A       = 0x40,
        PIT_B       = 0x41,
        PIT_C       = 0x42,
        PIT_CONTROL = 0x43,
        PIT_MASK    = 0xFF,
        PIT_SCALE   = 1193180,
        PIT_SET     = 0x36
    }

    static void Initialize(int frequency) {
        int divisor = PIT_SCALE / frequency;

        Port.Write(PIT_CONTROL, PIT_SET);
        Port.Write(PIT_A, divisor & PIT_MASK);
        Port.Write(PIT_A, (divisor >> 8) & PIT_MASK);

        //TODO: DeviceManager.RequestIRQ(&IRQHandler, 0);
    }

    private static void IRQHandler(ref InterruptStack stack) {
        //TODO: Task.Yield();
    }
}
