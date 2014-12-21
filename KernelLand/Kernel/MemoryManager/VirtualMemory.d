/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
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
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
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
import ObjectManager;

alias v_addr = ulong;
alias p_addr = ulong;


abstract final class VirtualMemory {
    private __gshared v_addr _regions = 0xFFFFFFFF_E0000000;

	private __gshared v_addr function(size_t size) _malloc = &TmpAlloc;
	private __gshared void function(v_addr ptr) _free;

	__gshared Paging KernelPaging;
	__gshared Heap KernelHeap;

	static void Initialize() {
		KernelHeap = new Heap(cast(v_addr)PhysicalMemory.AllocPage(1), Heap.MIN_SIZE, Heap.CalculateIndexSize(Heap.MIN_SIZE));

        _malloc = function(size_t size) {
            return KernelHeap.Alloc(size);
        };
        
        _free = function(v_addr ptr) {
            KernelHeap.Free(ptr);
        };
	}

    static v_addr AllocAlignedBlock(size_t num) {
        if (_malloc == &TmpAlloc)
            return PhysicalMemory.AllocPage(num);
        else {
            v_addr ret = _regions;
            _regions += num * Paging.PAGE_SIZE;
            return ret;
        }
    }

	private static v_addr TmpAlloc(size_t size) {
		return PhysicalMemory.AllocPage(size / 0x1000);
	}
}

extern(C) void* malloc(size_t size, int ba) {
	v_addr ret = VirtualMemory._malloc(size);
	//Log.WriteJSON("MemoryAlloc", "{", "size", size, "ba", ba, "address", cast(ulong)ret, "}");
	return cast(void *)ret;
}

extern(C) void free(void* ptr) {
	//Log.WriteJSON("MemoryFree", cast(ulong)ptr);

	VirtualMemory._free(cast(v_addr)ptr);
}