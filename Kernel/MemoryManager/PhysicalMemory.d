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

module MemoryManager.PhysicalMemory;

import Core;
import Library;
import Architecture;
import MemoryManager;

enum RegionType {
    Unknown,
    Free,
    Rserved,
    AcpiReclaimableMemory,
    AcpiNVSMemory,
    BadMemory,
    ISA_DMA_Memory,
    KernelMemory,
    InitrdMemory,
    VideoBackbuffer
}

struct RegionInfo {
    ulong Start;
    ulong Length;
    RegionType Type;
}

abstract final class PhysicalMemory {
    enum USER_MIN     = 0x10000;
    enum USER_LIB_MAX = 0xFFFFFFFF_70000000;
    enum MODULE_MIN   = 0xFFFFFFFF_D0000000;
    enum MODULE_MAX   = 0xFFFFFFFF_E0000000;

    enum MAX_REGIONS = 32;
    private __gshared RegionInfo[MAX_REGIONS] m_regions;
    private __gshared int m_regionIterator;

    private __gshared ulong m_startMemory;
    private __gshared BitArray m_frames;

    /* Used in Multiboot info for shifting addr to the end of the modules */
    @property static ref ulong MemoryStart() {
        return m_startMemory;
    }

    static void Initialize() {
        m_frames = new BitArray(0x10_000, false); //Hack: treba zvetsit paging tabulky v Boot.s lebo sa kernel potom nevie premapovat pre nedostatok pamete :/
        //nastravit vsetky bity, ktore niesu v region infe ako available na true

        VirtualMemory.KernelPaging = new Paging();
        for (void* i = 0xFFFFFFFF_80000000; i < 0xFFFFFFFF_8A000000; i += Paging.PAGE_SIZE)
            VirtualMemory.KernelPaging.AllocFrame(i, AccessMode.DefaultUser); //TODO: testing

        VirtualMemory.KernelPaging.Install();
        //for (v_addr i = 0xFFFFFFFF_E0000000; i < 0xFFFFFFFF_EA000000; i += Paging.PAGE_SIZE)
            //VirtualMemory.KernelPaging.AllocFrame(i, AccessMode.DefaultKernel);
    }

    /* Used by Paging only */
    package static void AllocFrame(ref PTE page, AccessMode mode) {
        if (page.Present)
            return;

        long index      = m_frames.FirstFreeBit();
        m_frames[index] = true;
        page.Address    = index;
        page.Mode       = mode;
    }

    /* Used by Paging only */
    package static void FreeFrame(ref PTE page) {
        if (!page.Present)
            return;

        m_frames[page.Address] = false;
        page.Present           = false;
    }

    static void* AllocPage(size_t num) {
        if (num < 1)
            num = 1;

        void* ret     = cast(void *)LinkerScript.KernelEnd + m_startMemory;
        m_startMemory += 0x1000 * num;

        return ret;
    }

    static void AddRegion(RegionInfo info) {
        if (m_regionIterator < MAX_REGIONS)
            m_regions[m_regionIterator++] = info;
    }
}
