/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
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
