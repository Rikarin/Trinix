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

module Architectures.x86_64.Core.GDT;

import Library;
import ObjectManager;
import MemoryManager;
import Architecture;
import Architectures.x86_64.Core;

private extern(C) void _CPU_refresh_iretq();


abstract final class GDT {
	private __gshared GlobalDescriptorTable*[256] _tables;

	@property static GlobalDescriptorTable* Table() {
		return _tables[CPU.Identifier];
	}

	static void Initialize() {
		_tables[CPU.Identifier] = new GlobalDescriptorTable;
		InitTable(CPU.Identifier);

        asm {
            "lgdt [RAX]" : : "a"(&_tables[CPU.Identifier].Base);
            "call _CPU_refresh_iretq";
        }
	}
	
	private static void InitTable(uint table) {
		_tables[table].Base.Limit = (SegmentDescriptor.sizeof * _tables[table].Entries.length) - 1;
		_tables[table].Base.Base	= cast(ulong)_tables[table].Entries.ptr;
		
		//Null
		_tables[table].SetNull(0);
		
		//Kernel
		_tables[table].SetCodeSegment(1, false, 0, true);
		_tables[table].SetDataSegment(2, true, 0);
		
		//User 64
		_tables[table].SetDataSegment(3, true, 3);
		_tables[table].SetCodeSegment(4, true, 3, true);

		//User 32
		_tables[table].SetDataSegment(5, true, 3);
	}
	
	private struct GDTBase {
	align(1):
		ushort Limit;
		ulong Base;
	}
	
	private struct CodeSegmentDescriptor {
	align(1):
		ushort Limit = 0xFFFF;
		ushort Base = 0x0000;
		ubyte BaseMid = 0x00;
		private ubyte Flags1 = 0b11111101;
		private ubyte Flags2 = 0b00000000;
		ubyte BaseHigh = 0x00;
		
		mixin(Bitfield!(Flags1, "zero3", 2, "c", 1, "ones0", 2, "dpl", 2, "p", 1));
		mixin(Bitfield!(Flags2, "zero4", 5, "l", 1, "d", 1, "Granularity", 1));
	}
	
	private struct DataSegmentDescriptor {
	align(1):
		ushort Limit = 0xFFFF;
		ushort Base = 0x0000;
		ubyte BaseMid = 0x00;
		private ubyte Flags1 = 0b11110011;
		private ubyte Flags2 = 0b11001111;
		ubyte BaseHigh = 0x00;
		
		mixin(Bitfield!(Flags1, "zero4", 5, "dpl", 2, "p", 1));
	}
	
	private struct SystemSegmentDescriptor {
	align(1):
		ushort LimitLo;
		ushort BaseLo;
		ubyte BaseMidLo;
		private ubyte Flags1;
		private ubyte Flags2;
		ubyte BaseMidHi;
		
		mixin(Bitfield!(Flags1, "Type", 4, "Zero0", 1, "dpl", 2, "p", 1));
		mixin(Bitfield!(Flags2, "LimitHi", 4, "avl", 1, "Zero1", 2, "g", 1));
	}
	
	private struct SystemSegmentExtension {
	align(1):
		uint BaseHi;
		private uint reserved;
	}
	
	private union SegmentDescriptor {
	align(1):
		DataSegmentDescriptor	DataSegment;
		CodeSegmentDescriptor	CodeSegment;
		SystemSegmentDescriptor	SystemSegmentLo;
		SystemSegmentExtension	SystemSegmentHi;
		
		ulong Value;
	}
	
	private struct GlobalDescriptorTable {
		GDTBase Base;
		SegmentDescriptor[64] Entries;
		
		void SetNull(uint index) {
			Entries[index].Value = 0;
		}
		
		void SetCodeSegment(uint index, bool conforming, ubyte DPL, bool present) {
			Entries[index].CodeSegment = CodeSegmentDescriptor.init;
			
			with (Entries[index].CodeSegment) {
				c = conforming;
				dpl = DPL;
				p = present;
				l = true;
				d = false;
			}
		}
		
		void SetDataSegment(uint index, bool present, ubyte DPL) {
			Entries[index].DataSegment	= DataSegmentDescriptor.init;
			Entries[index].DataSegment.p = present;
			Entries[index].DataSegment.dpl	= DPL;
		}
		
		void SetSystemSegment(uint index, uint limit, ulong base, SystemSegmentType segType, ubyte DPL, bool present, bool avail, bool granularity) {
			Entries[index].SystemSegmentLo = SystemSegmentDescriptor.init;
			Entries[index + 1].SystemSegmentHi = SystemSegmentExtension.init;
			
			with (Entries[index].SystemSegmentLo) {
				BaseLo = (base & 0xFFFF);
				BaseMidLo = (base >> 16) & 0xFF;
				BaseMidHi = (base >> 24) & 0xFF;
				
				LimitLo = limit & 0xFFFF;
				LimitHi = (limit >> 16) & 0xF;
				
				Type = segType;
				dpl = DPL;
				p = present;
				avl = avail;
				g = granularity;
			}
			
			Entries[index + 1].SystemSegmentHi.BaseHi = (base >> 32) & 0xFFFFFFFF;
		}
	}
}