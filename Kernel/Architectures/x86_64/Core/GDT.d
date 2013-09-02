module Architectures.x86_64.Core.GDT;

import System.Collections.All;

import MemoryManager.Memory;
import MemoryManager.PageAllocator;

import Architectures.CPU;
import Architectures.x86_64.Core.Descriptor;


class GDT {
static:
	__gshared GlobalDescriptorTable*[256] Tables;
	
	bool Init() { return true; }
	
	bool Install() {
		GlobalDescriptorTable* gdt = cast(GlobalDescriptorTable *)PageAllocator.AllocPage();
		*gdt = GlobalDescriptorTable.init;
		Tables[CPU.Identifier] = gdt;
		InitTable(CPU.Identifier);
		
		GDTBase gdtBase = gdt.gdtBase;
		asm {
			lgdt [gdtBase];
			call _CPU_refresh_iretq;
		}
		return true;
	}	
	
	
package:
	void InitTable(uint table) {
		Tables[table].gdtBase.Limit = (SegmentDescriptor.sizeof * Tables[table].Entries.length) - 1;
		Tables[table].gdtBase.Base	= cast(ulong)Tables[table].Entries.ptr;
		
		//Null
		Tables[table].SetNull(0);
		
		//Kernel
		Tables[table].SetCodeSegment(1, false, 0, true);
		Tables[table].SetDataSegment(2, true, 0);
		
		//User
		Tables[table].SetDataSegment(3, true, 3);
		Tables[table].SetCodeSegment(4, true, 3, true);
	}
	
	struct GDTBase {
	align(1):
		ushort Limit;
		ulong Base;
	}
	
	struct CodeSegmentDescriptor {
	align(1):
		ushort Limit	= 0x0000;
		ushort Base		= 0x0000;
		ubyte BaseMid	= 0x00;
		ubyte Flags1	= 0b11111101;
		ubyte Flags2	= 0b00000000;
		ubyte BaseHigh 	= 0x00;

		mixin(Bitfield!(Flags1, "zero3", 2, "c", 1, "ones0", 2, "dpl", 2, "p", 1));
		mixin(Bitfield!(Flags2, "zero4", 5, "l", 1, "d", 1, "Granularity", 1));
	}
	
	struct DataSegmentDescriptor {
	align(1):
		ushort Limit	= 0xFFFF;
		ushort Base		= 0x0000;
		ubyte BaseMid	= 0x00;
		ubyte Flags1	= 0b11110011;
		ubyte Flags2	= 0b11001111;
		ubyte BaseHigh 	= 0x00;

		mixin(Bitfield!(Flags1, "zero4", 5, "dpl", 2, "p", 1));
	}
	
	struct SystemSegmentDescriptor {
	align(1):
		ushort LimitLo;
		ushort BaseLo;
		ubyte BaseMidLo;
		ubyte Flags1;
		ubyte Flags2;
		ubyte BaseMidHi;
		
		mixin(Bitfield!(Flags1, "Type", 4, "Zero0", 1, "dpl", 2, "p", 1));
		mixin(Bitfield!(Flags2, "LimitHi", 4, "avl", 1, "Zero1", 2, "g", 1));
	}
	
	struct SystemSegmentExtension {
	align(1):
		uint BaseHi;
		uint Reserved = 0;
	}
	
	union SegmentDescriptor {
	align(1):
		DataSegmentDescriptor	DataSegment;
		CodeSegmentDescriptor	CodeSegment;
		SystemSegmentDescriptor	SystemSegmentLo;
		SystemSegmentExtension	SystemSegmentHi;
		
		ulong Value;
	}
	
	struct GlobalDescriptorTable {
		GDTBase gdtBase;
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
			Entries[index].DataSegment		= DataSegmentDescriptor.init;
			Entries[index].DataSegment.p 	= present;
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