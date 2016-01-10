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

module Architectures.x86_64.Core.TSS;

import Architecture;
import MemoryManager;
import Architectures.x86_64.Core;


struct TaskStateSegment {
align(1):
    private uint   m_reserved0;

    void*          RSP0;
    private        void* m_rsp1;
    private        void* m_rsp2;

    private ulong  m_reserved1;
    private        void*[7] m_ist;
    private ulong  m_reserved2;
    private ushort m_reserved3;

    private ushort m_ioMap;
}


abstract final class TSS {
    private enum TSS_BASE = 0x28;
    private __gshared TaskStateSegment*[256] m_segments;

    @property static TaskStateSegment* Table() { return m_segments[CPU.Identifier]; }

    static void Initialize() {
        m_segments[CPU.Identifier] = new TaskStateSegment();
        GDT.Table.SetSystemSegment((TSS_BASE >> 3), TaskStateSegment.sizeof, cast(void *)m_segments[CPU.Identifier],
                                   SystemSegmentType.AvailableTSS, 0, true, false, false);

        ushort base = TSS_BASE;
        asm {
            ltr base;
        }
    }
}
