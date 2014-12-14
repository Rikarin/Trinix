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

module MemoryManager.PhysicalMemory;

import Library;
import Architecture;
import MemoryManager;


abstract final class PhysicalMemory {
	private __gshared ulong _startMemory;
	private __gshared BitArray _frames;

	// Used in Multiboot info for shifting addr to the end of the modules
	@property static ulong MemoryStart() {
		return _startMemory;
	}

	@property static void MemoryStart(ulong addr) {
		_startMemory = addr;
	}

	static bool Initialize() {
		_frames = new BitArray(0x10_000, false); //Hack: treba zvetsit paging tabulky v Boot.s lebo sa kernel potom nevie premapovat pre nedostatok pamete :/

		VirtualMemory.KernelPaging = new Paging();
		for (ulong i = 0xFFFFFFFF80000000; i < 0xFFFFFFFF8A000000; i += 0x1000)
			VirtualMemory.KernelPaging.AllocFrame(cast(void *)i, AccessMode.DefaultUser); //TODO: testing

        VirtualMemory.KernelPaging.Install();
		return true;
	}

	// Used by Paging
	package static void AllocFrame(ref PTE page, AccessMode mode) {
		if (page.Present)
			return;
		
		long index = _frames.FirstFreeBit();
		_frames[index] = true;
		page.Address = index;
		page.Mode = mode;
	}

	// Used by Paging
	package static void FreeFrame(ref PTE page) {
		if (!page.Present)
			return;
		
		_frames[page.Address] = false;
		page.Present = false;
	}

	static void* AllocPage(long count = 1) {
		if (count < 1)
			count = 1;
			
		void* ret = LinkerScript.KernelEnd + _startMemory;
		_startMemory += 0x1000 * count;

		return ret;
	}
}