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

module MemoryManager.VirtualMemory;

import Core;
import MemoryManager;


abstract final class VirtualMemory {
    private __gshared void* m_regions = cast(void *)0xFFFFFFFF_E0000000;

    private __gshared void* function(size_t size) m_malloc = &TmpAlloc;
    private __gshared void function(void* ptr) m_free;

    __gshared IPaging KernelPaging;
    __gshared Heap KernelHeap;

    static void Initialize() {
        KernelHeap = new Heap(cast(void *)PhysicalMemory.AllocPage(1), Heap.MIN_SIZE, Heap.CalculateIndexSize(Heap.MIN_SIZE));

        m_malloc = function(size_t size) {
            return KernelHeap.Alloc(size);
        };

        m_free = function(v_addr ptr) {
            KernelHeap.Free(ptr);
        };
    }

    //TODO: Use Mutex
    static byte[] MapRegion(void* pAddr, size_t length) {
        byte[] result = MapRegion(pAddr, m_regions, length);
        m_regions += (length & ~0xFFFUL) + ((length & 0xFFF) ? Paging.PAGE_SIZE : 0);// scope(exit)
        return result;
    }

    static byte[] MapRegion(void* pAddr, void* vAddr, size_t length) {
        for (ulong i = 0; i < length; i += Paging.PAGE_SIZE) {
            //PTE* pt = &KernelPaging.GetPage(vAdd + i);
            //TODO: tu sa to niekde pojebe s tou alokaciou a potom to uz nefici jak ma
          //  pt.Present   = true;
            /*pt.ReadWrite = true;
            pt.User      = true;
            pt.Address   = ((cast(ulong)pAdd + i) >> 12);*/
        }

       // int diff = cast(int)pAdd & 0xFFF;
        return null;//(cast(byte *)vAdd)[diff .. diff + length];
    }

    static void* AllocAlignedBlock(size_t num) {
        if (m_malloc == &TmpAlloc)
            return PhysicalMemory.AllocPage(num);
        else {
            void* ret  = m_regions;
            m_regions += num * Paging.PAGE_SIZE;
            return ret;
        }
    }

    private static void* TmpAlloc(size_t size) {
        return PhysicalMemory.AllocPage(size / 0x1000);
    }
}

extern(C) void* malloc(size_t size, int ba) {
    void* ret = VirtualMemory.m_malloc(size);
    //Log.WriteJSON("MemoryAlloc", "{", "size", size, "ba", ba, "address", cast(ulong)ret, "}");
    return cast(void *)ret;
}

extern(C) void free(void* ptr) {
    //Log.WriteJSON("MemoryFree", cast(ulong)ptr);

    VirtualMemory.m_free(cast(void *)ptr);
}
