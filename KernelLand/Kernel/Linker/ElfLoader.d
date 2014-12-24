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
module Linker.ElfLoader;

import Core;
import Linker;
import Library;
import VFSManager;
import MemoryManager;


class ElfLoader : BinaryLoader {
	private struct EHeader {
		ubyte[16] Identifier;
		ushort Type;
		ushort Machine;
		uint Version;
		ulong Entry;
		ulong ProgramHeaderOffset;
		ulong SectionHeaderOffset;
		uint Flags;
		ushort ElfHeaderSize;
		ushort ProgramHeaderEntrySize;
		ushort ProgramHeaderNumber;
		ushort SectionHeaderEntrySize;
		ushort SectionHeaderNumber;
		ushort TableIndex;
	}
	
	private struct SHeader {
		uint Name;
		uint Type;
		ulong Flags;
		ulong Address;
		ulong Offset;
		ulong Size;
		uint Link;
		uint Info;
		ulong AddressAlign;
		ulong EntrySize;
	}
	
	private struct PHeader {
		uint Type;
		uint Flags;
		ulong Offset;
		ulong VirtualAddress;
		private ulong PhysicalAddress;
		ulong FileSize;
		ulong MemorySize;
		ulong Align;
	}
	
	private struct Dynamic {
		long Tag;
		ulong Value;
	}
	
	private struct Symbol {
		uint Name;
		ubyte Info;
		ubyte Other;
		ushort SectionTableIndex;
		ulong Value;
		ulong Size;
	}
	
	private struct Relocation {
		ulong Offset;
		ulong Info;
	}
	
	private struct RelocationA {
		ulong Offset;
		ulong Info;
		long Addend;
	}
	
	private enum RelocationType {
		R_X86_64_NONE,
		R_X86_64_64,
		R_X86_64_PC32,
		R_X86_64_GOT32,
		R_X86_64_PLT32,
		R_X86_64_COPY,
		R_X86_64_GLOB_DAT,
		R_X86_64_JUMP_SLOT,
		R_X86_64_RELATIVE
	}
	
	enum {
		PT_NULL,    //0
		PT_LOAD,    //1
		PT_DYNAMIC, //2
		PT_INTERP,  //3
		PT_NOTE,    //4
		PT_SHLIB,   //5
		PT_PHDR,    //6
		PT_LOPROC = 0x70000000,
		PT_HIPROC = 0x7fffffff
	}

	enum {
		PF_X = 1,
		PF_W = 2,
		PF_R = 4
	}
	
	enum {
		DT_NULL,    //!< Marks End of list
		DT_NEEDED,  //!< Offset in strtab to needed library
		DT_PLTRELSZ,    //!< Size in bytes of PLT
		DT_PLTGOT,  //!< Address of PLT/GOT
		DT_HASH,    //!< Address of symbol hash table
		DT_STRTAB,  //!< String Table address
		DT_SYMTAB,  //!< Symbol Table address
		DT_RELA,    //!< Relocation table address
		DT_RELASZ,  //!< Size of relocation table
		DT_RELAENT, //!< Size of entry in relocation table
		DT_STRSZ,   //!< Size of string table
		DT_SYMENT,  //!< Size of symbol table entry
		DT_INIT,    //!< Address of initialisation function
		DT_FINI,    //!< Address of termination function
		DT_SONAME,  //!< String table offset of so name
		DT_RPATH,   //!< String table offset of library path
		DT_SYMBOLIC,//!< Reverse order of symbol searching for library, search libs first then executable
		DT_REL, //!< Relocation Entries (Elf32_Rel instead of Elf32_Rela)
		DT_RELSZ,   //!< Size of above table (bytes)
		DT_RELENT,  //!< Size of entry in above table
		DT_PLTREL,  //!< Relocation entry of PLT
		DT_DEBUG,   //!< Debugging Entry - Unknown contents
		DT_TEXTREL, //!< Indicates that modifcations to a non-writeable segment may occur
		DT_JMPREL,  //!< Address of PLT only relocation entries
		DT_LOPROC = 0x70000000, //!< Low Definable
		DT_HIPROC = 0x7FFFFFFF  //!< High Definable
	}

	private EHeader _eHeader;
	private PHeader[] _pHeader;

	private this() {
		super();
	}

	static ElfLoader Load(FSNode node) {
		EHeader header;
		node.Read(0, header.ToArray());

		/* Sanity check */
		if (header.Identifier[0] != 0x7F || header.Identifier[1] != 'E' ||
		header.Identifier[2] != 'L'  || header.Identifier[3] != 'F') {
			Log("ELF: Non-ELF file was passed to ELF loader!");
			return null;
		}

		if (header.Identifier[4] != 2) {
			Log("ELF: Not supported version format. only x86_64 is supported!");
			return null;
		}

		if (!header.ProgramHeaderOffset) {
			Log("ELF: Program header was not found!");
			return null;
		}

		if (header.ProgramHeaderEntrySize != PHeader.sizeof) {
			Log("ELF: Wrong program entry size. Given %x, needed %x", header.ProgramHeaderEntrySize, PHeader.sizeof);
			return null;
		}

		if (header.SectionHeaderEntrySize != SHeader.sizeof) {
			Log("ELF: Wrong section entry size. Given %x, needed %x", header.SectionHeaderEntrySize, SHeader.sizeof);
			return null;
		}

		debug {
			Log("\nELF Header");
			Log("---------------------");
			Log(" Identifier = %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x",
			    header.Identifier[0], header.Identifier[1], header.Identifier[2], header.Identifier[3],
			header.Identifier[4], header.Identifier[5], header.Identifier[6], header.Identifier[7],
			header.Identifier[8], header.Identifier[9], header.Identifier[10], header.Identifier[11],
			header.Identifier[12], header.Identifier[13], header.Identifier[14], header.Identifier[15]
			);

			Log(" Type    = %d", header.Type);
			Log(" Machine = %d", header.Machine);
			Log(" Version = %d", header.Version);
			Log(" Entry   = %x", header.Entry);
			Log(" PHOff   = %x", header.ProgramHeaderOffset);
			Log(" SHOff   = %x", header.SectionHeaderOffset);
			Log(" Flags   = %x", header.Flags);
			Log(" EHSize  = %d", header.ElfHeaderSize);
			Log(" PHESize = %d", header.ProgramHeaderEntrySize);
			Log(" PHNum   = %d", header.ProgramHeaderNumber);
			Log(" SHESize = %d", header.SectionHeaderEntrySize);
			Log(" SHNum   = %d", header.SectionHeaderNumber);
			Log(" Table   = %d", header.TableIndex);
		}

		PHeader[] pHeader = new PHeader[header.ProgramHeaderNumber];
		node.Read(header.ProgramHeaderOffset, pHeader.ToArrayA());

		int loadSegments;
		foreach (x; pHeader)
			if (x.Type == PT_LOAD)
				loadSegments++;

		auto ret      = new ElfLoader();
		ret._eHeader  = header;
		ret._pHeader  = pHeader;
		ret._base     = ~0UL;
		ret._entry    = header.Entry;
		ret._sections = new BinarySection[loadSegments];

		int j;
		foreach (i, x; pHeader) {
			debug {
				Log("\nProgram Header #%d", i);
				Log("---------------------");

				Log(" Type     = %d", x.Type);
				Log(" Flags    = %x", x.Flags);
				Log(" Offset   = %x", x.Offset);
				Log(" VAddr    = %x", x.VirtualAddress);
				Log(" PAddr    = %x", x.PhysicalAddress);
				Log(" FileSyze = %x", x.FileSize);
				Log(" MemSize  = %x", x.MemorySize);
				Log(" Align    = %x", x.Align);
			}

			if (x.Type == PT_INTERP) {
				if (ret._interpreter)
					continue;

				char[] name = new char[x.FileSize];
				node.Read(x.Offset, name.ToArrayA());
				//TODO: Register interpreter

				Log("Interpreter '%s'", name);
			}

			if (x.Type != PT_LOAD)
				continue;

			if (x.VirtualAddress < ret._base)
				ret._base = x.VirtualAddress;

			ret._sections[j].Flags          = 0;
			ret._sections[j].Offset         = x.Offset;
			ret._sections[j].FileSize       = x.FileSize;
			ret._sections[j].MemorySize     = x.MemorySize;
			ret._sections[j].VirtualAddress = x.VirtualAddress;

			if(!(x.Flags & PF_W))
				ret._sections[j].Flags |= BinaryLoader.SectionFlag.ReadOnly;

			if (x.Flags & PF_X)
				ret._sections[j].Flags |= BinaryLoader.SectionFlag.Executable;
			j++;
		}

		return ret;
	}

	

	private Dynamic* _dynamic;
	private Symbol* _symbol;
	private v_addr _baseDiff;
	private v_addr _stringTable;
	private v_addr _hashTable;

	
	private void ParseTables() {
		/* check if binary is mapped */
		if (!_mappedBinary) {
			Log("ELF Relocation: Binary is not mapped!");
			return;
		}

		/* Scan for dynamic table */
		foreach (x; _pHeader) {
			if (x.Type == PT_DYNAMIC)
				_dynamic = cast(Dynamic *)x.VirtualAddress;
			else if (x.Type == PT_LOAD && _baseDiff > x.VirtualAddress)
				_baseDiff = x.VirtualAddress;
		}

		if (_dynamic is null)
			return;

		_baseDiff = _mappedBinary - _baseDiff;
		_dynamic  = cast(Dynamic *)(cast(v_addr)_dynamic + _baseDiff);
		Log("BaseDiff = %x", _baseDiff);

		/* Parse dynamic table */
		for (int i = 0; _dynamic[i].Tag != DT_NULL; i++) {
			switch (_dynamic[i].Tag) {
				case DT_SYMTAB:
					_dynamic[i].Value += _baseDiff;
					_symbol = cast(Symbol *)_dynamic[i].Value;
					break;
					
				case DT_STRTAB:
					_dynamic[i].Value += _baseDiff;
					_stringTable = _dynamic[i].Value;
					break;
					
				case DT_HASH:
					_dynamic[i].Value += _baseDiff;
					_hashTable = _dynamic[i].Value;
					break;
					
				default:
			}
		}
	}

	

	

	
	public v_addr Relocate() {
		if (!_baseDiff)
			ParseTables();

		if (_dynamic is null) {
			Log("ELF Relocation: No PT_DYNAMIC segment");
			return cast(ulong)_eHeader.Entry + _baseDiff;
		}

		if (_symbol is null || !_stringTable || !_hashTable) {
			Log("ELF Relocation: Missing symbol, string table or hash table");
			return 0;
		}

		

		Log("%s(%d): number of symbols: %d", __FILE__, __LINE__, (cast(uint *)_hashTable)[1]);

		
		Relocation* relocation;
		RelocationA* relocationA;
		long relocationCount;
		long relocationACount;
		v_addr pltRel;
		long pltSize;
		long pltType;
		
		for (int i = 0; _dynamic[i].Tag != DT_NULL; i++) {
			switch (_dynamic[i].Tag) {
				case DT_SONAME:
					break;
					
				case DT_NEEDED:
					Log("ELF Relocation: Modules cannot load library");
					return 0;
					
				case DT_REL:
					_dynamic[i].Value += _baseDiff;
					relocation = cast(Relocation *)_dynamic[i].Value;
					break;
					
				case DT_RELSZ:
					relocationCount = _dynamic[i].Value / Relocation.sizeof;
					break;
					
				case DT_RELENT:
					if (_dynamic[i].Value != Relocation.sizeof) {
						Log("ELF Relocation: DT_RELENT != Relocation.sizeof");
						return 0;
					}
					break;
					
				case DT_RELA:
					_dynamic[i].Value += _baseDiff;
					relocationA = cast(RelocationA *)_dynamic[i].Value;
					break;
					
				case DT_RELASZ:
					relocationACount = _dynamic[i].Value / RelocationA.sizeof;
					break;
					
				case DT_RELAENT:
					if (_dynamic[i].Value != RelocationA.sizeof) {
						Log("ELF Relocation: DT_RELAENT != RelocationA.sizeof");
						return 0;
					}
					break;
					
				case DT_JMPREL:
					_dynamic[i].Value += _baseDiff;
					pltRel = _dynamic[i].Value;
					break;
					
				case DT_PLTREL:
					pltType = _dynamic[i].Value;
					break;
					
				case DT_PLTRELSZ:
					pltSize = _dynamic[i].Value;
					break;
					
				default:
			}
		}

		bool fail;
		if (relocation) {
			Log("Rel count = %d", relocationCount);
			
			foreach (x; relocation[0 .. relocationCount]) {
				ulong ptr = x.Offset + _baseDiff;
				fail |= DoReloc(x.Info, ptr, *(cast(ulong *)ptr));
			}
		}
		
		if (relocationA) {
			Log("Rela count = %d", relocationACount);
			
			foreach (x; relocationA[0 .. relocationACount])
				fail |= DoReloc(x.Info, x.Offset + _baseDiff, x.Addend);
		}
		
		if (pltRel && pltType) {
			if (pltType == DT_REL) {
				Relocation* plt = cast(Relocation *)pltRel;
				ulong count = pltSize / Relocation.sizeof;
				
				Log("plt rel count = %d", count);
				foreach (x; plt[0 .. count]) {
					ulong ptr = x.Offset + _baseDiff;
					fail |= DoReloc(x.Info, ptr, *(cast(ulong *)ptr));
				}
			} else {
				RelocationA* plt = cast(RelocationA *)pltRel;
				ulong count = pltSize / RelocationA.sizeof;
				
				Log("plt rela count = %d", count);
				foreach (x; plt[0 .. count])
					fail |= DoReloc(x.Info, x.Offset + _baseDiff, x.Addend);
			}
		}
		
		if (fail) {
			Log("Jolanda: Spadlo to!");
			return 0;
		}
		
		v_addr ret = cast(ulong)_eHeader.Entry + _baseDiff;
		Log("relocation done ptr = %x", cast(ulong)ret);
		return ret;
	}

	bool GetSymbol(string name, ref v_addr ret, ref long size) {
		if (_dynamic is null) {
			Log("ELF Relocation: Unable to find PT_DYNAMIC segment");
			return false;
		}

		uint* pBuckets = cast(uint *)_hashTable;
		uint nBuckets = pBuckets[0];
		pBuckets = &pBuckets[2];
		uint* pCahins = &pBuckets[nBuckets];
		
		uint nameHash = HashName(name);
		nameHash %= nBuckets;

		int i = pBuckets[nameHash];
		//Log("err, name1: %s", name);
		if (_symbol[i].SectionTableIndex && (cast(char *)(_stringTable + cast(ulong)_symbol[i].Name)).ToString() == name) {
			ret = _symbol[i].Value + _baseDiff;
			size = _symbol[i].Size;

			Log("Name: %s, Return: %x", name, ret);
			return true;
		}
		
		while (pCahins[i]) {
			i = pCahins[i];

			if (_symbol[i].SectionTableIndex && (cast(char *)(_stringTable + cast(ulong)_symbol[i].Name)).ToString() == name) {
				ret = _symbol[i].Value + _baseDiff;
				size = _symbol[i].Size;

				Log("Name: %s, Return: %x", name, ret);
				return true;
			}
		}

		return false;
	}
	
	private bool DoReloc(ulong info, v_addr ptr, long addend) {
		int sym = cast(int)(info >> 32);
		int type = cast(int)(info & 0xFFFFFFFF);
		string symName = (cast(char *)(_stringTable + cast(ulong)_symbol[sym].Name)).ToString();
		v_addr symval;
		long size;

		switch (type) {
			case RelocationType.R_X86_64_NONE:
				break;
				
			case RelocationType.R_X86_64_64:
				if (!GetSymbol(symName, symval, size))
					return false;
				
				*cast(ulong *)ptr = cast(ulong)symval + addend;
				break;
				
			case RelocationType.R_X86_64_COPY:
				if (!GetSymbol(symName, symval, size))
					return false;
				
				(cast(byte *)ptr)[0 .. size] = (cast(byte *)symval)[0 .. size];
				break;
				
			case RelocationType.R_X86_64_GLOB_DAT:
				goto case RelocationType.R_X86_64_JUMP_SLOT;
				
			case RelocationType.R_X86_64_JUMP_SLOT:
				if (!GetSymbol(symName, symval, size))
					return false;
				
				*cast(ulong *)ptr = cast(ulong)symval;
				break;
				
			case RelocationType.R_X86_64_RELATIVE:
				*cast(ulong *)ptr = cast(ulong)_base + addend;
				break;
				
			default:
				return false;
		}
		
		return true;
	}

	private uint HashName(string name) {
		uint h;
		uint g;
		
		foreach (x; name) {
			h = (h << 4) + x;
			if ((g = h) & 0xF0000000)
				h ^= g >> 24;
			
			h &= ~g;
		}
		
		return h;
	}
}