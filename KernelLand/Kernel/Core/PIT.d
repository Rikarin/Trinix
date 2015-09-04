/**
* Copyright (c) 2014-2015 Trinix Foundation. All rights reserved.
* 
* This file is part of Trinix Operating System and is released under Trinix 
* Public Source Licence Version 1.0 (the 'Licence'). You may not use this file
* except in compliance with the License. The rights granted to you under the
* License may not be used to create, or enable the creation or redistribution
* of, unlawful or unlicensed copies of an Trinix operating system, or to
* circumvent, violate, or enable the circumvention or violation of, any terms
* of an Trinix operating system software license agreement.
* 
* You may obtain a copy of the License at
* https://github.com/Bloodmanovski/Trinix and read it before using this file.
* 
* The Original Code and all software distributed under the License are
* distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
* KIND, either express or implied. See the License for the specific language
* governing permissions and limitations under the License.
* 
* Contributors:
*      Matsumoto Satoshi <satoshi@gshost.eu>
*/

module Core.PIT;

import TaskManager;
import Architecture;
import ObjectManager;


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

        DeviceManager.RequestIRQ(&IRQHandler, 0);
    }

    private static void IRQHandler(ref InterruptStack stack) {
        Task.Scheduler();
    }
}