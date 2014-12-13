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


abstract final class VirtualMemory : IStaticModule {
	private __gshared void* function(long size) _malloc = &TmpAlloc;
	private __gshared void function(void* ptr) _free;

	__gshared Paging KernelPaging;
	__gshared Heap KernelHeap;

	static bool Initialize() {
		Log.WriteJSON("module", "{");
		Log.WriteJSON("name", "Heap");
		Log.WriteJSON("type", "Initialize");
		KernelHeap = new Heap(cast(ulong)PhysicalMemory.AllocPage(), Heap.MinSize, Heap.CalculateIndexSize(Heap.MinSize));
		Log.WriteJSON("value", "True");
		Log.WriteJSON("}");

		return true;
	}

	static bool Install() {
		Log.WriteJSON("module", "{");
		Log.WriteJSON("name", "Heap");
		Log.WriteJSON("type", "Install");

		_malloc = function(long size) {
			return KernelHeap.Alloc(size);
		};

		_free = function(void* ptr) {
			KernelHeap.Free(ptr);
		};

		Log.WriteJSON("value", "True");
		Log.WriteJSON("}");
		return true;
	}

	private static void* TmpAlloc(long size) {
		return PhysicalMemory.AllocPage(size / 0x1000);
	}
}

extern(C) void* malloc(long size, int ba) {
	void* ret = VirtualMemory._malloc(size);
	//Log.WriteJSON("MemoryAlloc", "{", "size", size, "ba", ba, "address", cast(ulong)ret, "}");
	return ret;
}

extern(C) void free(void* ptr) {
	//Log.WriteJSON("MemoryFree", cast(ulong)ptr);

	VirtualMemory._free(ptr);
}