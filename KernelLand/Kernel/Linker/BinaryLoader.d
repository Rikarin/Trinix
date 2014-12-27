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
 * http://bit.ly/1wIYh3A and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */
module Linker.BinaryLoader;

import Core;
import Linker;
import Library;
import VFSManager;
import Architecture;
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

    private struct KernelSymbol {
    align(1):
        v_addr Address;
        char Name;
    }

	private __gshared LinkedList!BinaryLoader m_binaries;
	private __gshared LinkedList!BinaryLoaderType m_loaders;

	private FSNode m_node;
	private long m_referenceCount;
	protected v_addr m_mappedBinary;

	protected v_addr m_base;
	protected v_addr m_entry;
	protected string m_interpreter;
	protected BinarySection[] m_sections;

	
	/*   @property ref long ReferenceCount() {
	 return _referenceCount;
	 }*/
	
	protected this() {
		m_binaries.Add(this);
	}

	~this() {
		m_binaries.Remove(this);
	}

	v_addr Relocate() {
		Log("BinaryLoader: Relocation not supported!");
		return 0;
	}

	static void Initialize() {
		m_binaries = new LinkedList!BinaryLoader();
		m_loaders  = new LinkedList!BinaryLoaderType();

		//TODO: move to elf initialization
		BinaryLoaderType elf = { 0x464C457F, 0xFFFFFFFF, &ElfLoader.Load };
		m_loaders.Add(elf);

        Log("Starts at %x", LinkerScript.KernelSymbols);

        for (auto sym = cast(KernelSymbol *)LinkerScript.KernelSymbols;
             cast(v_addr)sym < LinkerScript.KernelSymbolsEnd;) {
            string name = (&sym.Name).ToString();
           // Log("Symbol %s at address %x", name, sym.Address);

            sym += KernelSymbol.sizeof + name.length;
        }
	}

	static void Finalize() {
		delete m_binaries;
		delete m_loaders;
	}

	static BinaryLoader LoadKernel(FSNode node) {
		BinaryLoader bin = FindLoadedBinary(node);

		if (bin !is null) /* Already loaded */
			return bin;

		bin = DoLoad(node);
		if (bin is null)
			return null;
		
		bin.m_referenceCount++; /* This will be never unloaded */
		bin.MapIn(KLIB_LOWEST, KLIB_HIGHEST);

		m_binaries.Add(bin);
		return bin;
	}

	private static BinaryLoader FindLoadedBinary(FSNode node) {
		auto bin = Array.Find(m_binaries, (LinkedListNode!BinaryLoader o) => o.Value.m_node is node);

		if (bin is null)
			return null;

		return bin.Value;
	}

	private static BinaryLoader DoLoad(FSNode node) {
		BinaryLoader ret;
		uint magic;
		node.Read(0, magic.ToArray());

		foreach (x; m_loaders) {
			if (x.Value.Magic == (magic & x.Value.Mask)) {
				ret = x.Value.Load(node);
				break;
			}
		}

		if (ret is null)
			Log("BinaryLoader: '%s' is an unknown file type", node.Location);
		
		debug {
			Log("Interpreter: %s", ret.m_interpreter);
			Log("Base: %x, Entry: %x", ret.m_base, ret.m_entry);
			Log("NumSections: %d", ret.m_sections.length);
		}

		ret.m_node = node;
		return ret;
	}

	private void MapIn(ulong loadMin, ulong loadMax) {
		m_referenceCount++;
		ulong base = m_base;

		if (base) {
			foreach (x; m_sections) {
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
				for (i = 0; i < m_sections.length; i++) {
					v_addr addr = m_sections[i].VirtualAddress - m_base + base;
					size_t size = m_sections[i].MemorySize;

					if (addr + size > loadMax)
						break;
					
					if (!CheckFreeMemory(addr, size))
						break;
				}

				if (i == m_sections.length)
					break;

				base -= BIN_GRANULARITY;
			}
			Log("Allocated base %x", base);
		}

		if (base < loadMin) {
			Log("BinaryLoader: Executable '%s' cannot be loaded, not enought space", m_node.Location);
			return;
		}

		/* Map in */
		foreach(i, x; m_sections) {
			v_addr addr = x.VirtualAddress - m_base + base;
			Log("%d - %x, %x bytes form offset %x (%x)", i, addr, x.FileSize, x.Offset, x.Flags);
			VFS.MapIn(m_node, addr, x.FileSize, x.Offset);

			for (v_addr j = addr + x.FileSize; j < x.MemorySize - x.FileSize; j += Paging.PAGE_SIZE)
				VirtualMemory.KernelPaging.AllocFrame(j, AccessMode.DefaultKernel);
		}

		m_mappedBinary = base;
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