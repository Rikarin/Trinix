/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
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
