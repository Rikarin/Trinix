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
 * Matsumoto Satoshi <satoshi@gshost.eu>
 */
module Linker.BinaryLoader;

import Core;
import Linker;
import Library;
import VFSManager;
import MemoryManager;


struct BinaryLoaderType {
	uint Magic;
	uint Mask;
	BinaryLoader function(FSNode node) Load;
}

struct BinarySection {
	ulong Offset;
	v_addr VirtualAddress;
	ulong FileSize;
	ulong MemorySize;
	uint Flags;
}

class BinaryLoader {
	enum BIN_LOWEST       = PhysicalMemory.USER_MIN;
	enum BIN_GRANULARITY  = 0x10000;
	enum BIN_HIGHEST      = PhysicalMemory.USER_LIB_MAX - BIN_GRANULARITY;
	enum KLIB_LOWEST      = PhysicalMemory.MODULE_MIN;
	enum KLIB_GRANULARITY = 0x10000;
	enum KLIB_HIGHEST     = PhysicalMemory.MODULE_MAX - KLIB_GRANULARITY;

	enum SectionFlag {
		ReadOnly   = 1,
		Executable = 2
	}

	private __gshared LinkedList!BinaryLoader _binaries;
	private __gshared LinkedList!BinaryLoaderType _loaders;

	private FSNode _node;
	private long _referenceCount;
	protected v_addr _mappedBinary;

	protected v_addr _base;
	protected v_addr _entry;
	protected string _interpreter;
	protected BinarySection[] _sections;

	
	/*   @property ref long ReferenceCount() {
	 return _referenceCount;
	 }*/
	
	protected this() {
		_binaries.Add(this);
	}

	~this() {
		_binaries.Remove(this);
	}

	v_addr Relocate() {
		Log("BinaryLoader: Relocation not supported!");
		return 0;
	}

	static void Initialize() {
		_binaries = new LinkedList!BinaryLoader();
		_loaders  = new LinkedList!BinaryLoaderType();

		//TODO: move to elf initialization
		BinaryLoaderType elf = { 0x464C457F, 0xFFFFFFFF, &ElfLoader.Load };
		_loaders.Add(elf);
	}

	static void Finalize() {
		delete _binaries;
		delete _loaders;
	}

	static BinaryLoader LoadKernel(FSNode node) {
		BinaryLoader bin = FindLoadedBinary(node);

		if (bin !is null) /* Already loaded */
			return bin;

		bin = DoLoad(node);
		if (bin is null)
			return null;
		
		bin._referenceCount++; /* This will be never unloaded */
		bin.MapIn(KLIB_LOWEST, KLIB_HIGHEST);

		_binaries.Add(bin);
		return bin;
	}

	private static BinaryLoader FindLoadedBinary(FSNode node) {
		auto bin = Array.Find(_binaries, (LinkedListNode!BinaryLoader o) => o.Value._node is node);

		if (bin is null)
			return null;

		return bin.Value;
	}

	private static BinaryLoader DoLoad(FSNode node) {
		BinaryLoader ret;
		uint magic;
		node.Read(0, magic.ToArray());

		foreach (x; _loaders) {
			if (x.Value.Magic == (magic & x.Value.Mask)) {
				ret = x.Value.Load(node);
				break;
			}
		}

		if (ret is null)
			Log("BinaryLoader: '%s' is an unknown file type", node.Location);
		
		debug {
			Log("Interpreter: %s", ret._interpreter);
			Log("Base: %x, Entry: %x", ret._base, ret._entry);
			Log("NumSections: %d", ret._sections.length);
		}

		ret._node = node;
		return ret;
	}

	private void MapIn(ulong loadMin, ulong loadMax) {
		_referenceCount++;
		ulong base = _base;

		if (base) {
			foreach (x; _sections) {
				if (!CheckFreeMemory(x.VirtualAddress, x.MemorySize)) {
					base = 0;
					Log("BinaryLoader: Address %x is taken", x.VirtualAddress);
					break;
				}
			}
		}

		if (!base) {
			base = loadMax;
			while (base >= loadMin) {
				int i;
				for (i = 0; i < _sections.length; i++) {
					v_addr addr = _sections[i].VirtualAddress - _base + base;
					size_t size = _sections[i].MemorySize;

					if (addr + size > loadMax)
						break;
					
					if (!CheckFreeMemory(addr, size))
						break;
				}

				if (i == _sections.length)
					break;

				base -= BIN_GRANULARITY;
			}
			Log("Allocated base %x", base);
		}

		if (base < loadMin) {
			Log("BinaryLoader: Executable '%s' cannot be loaded, not enought space", _node.Location);
			return;
		}

		/* Map in */
		foreach(i, x; _sections) {
			v_addr addr = x.VirtualAddress - _base + base;
			Log("%d - %x, %x bytes form offset %x (%x)", i, addr, x.FileSize, x.Offset, x.Flags);
			VFS.MapIn(_node, addr, x.FileSize, x.Offset);

			for (v_addr j = addr + x.FileSize; j < x.MemorySize - x.FileSize; j += Paging.PAGE_SIZE)
				VirtualMemory.KernelPaging.AllocFrame(j, AccessMode.DefaultKernel);
		}

		_mappedBinary = base;
	}

	/* return true if memory is free */
	private bool CheckFreeMemory(v_addr start, size_t length) {
		length += start & (Paging.PAGE_SIZE - 1);
		length = (length + Paging.PAGE_SIZE - 1) & ~(Paging.PAGE_SIZE - 1);
		start &= ~(Paging.PAGE_SIZE - 1);

		for (; length > Paging.PAGE_SIZE; length -= Paging.PAGE_SIZE, start += Paging.PAGE_SIZE) {
			if (VirtualMemory.KernelPaging.GetPhysicalAddress(start))
				return false;
		}

		if (length == Paging.PAGE_SIZE && VirtualMemory.KernelPaging.GetPhysicalAddress(start))
			return false;

		return true;
	}
}