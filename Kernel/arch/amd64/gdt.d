/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module arch.amd64.gdt;

import arch.amd64.idt;
import arch.amd64.tss;
import common.address;
import common.bitfield;


abstract final class GDT {
@trusted: nothrow: @nogc:
static:
	private __gshared Base m_base;
	private __gshared SegmentDescriptor[64] m_tables;
	private __gshared TaskStateSegment m_tss;
	private __gshared ushort m_tssId;
	

    void init() {
		m_base.limit = cast(ushort)(SegmentDescriptor.sizeof * setupTable() - 1);
        m_base.base  = cast(ulong)m_tables.ptr;
		
		flush();
    }
	
	void flush() {
		auto base = &m_base;
		auto id = cast(ushort)(m_tssId * SegmentDescriptor.sizeof);
		
		asm pure nothrow @nogc {
			mov RAX, base;
            lgdt [RAX];
            call __refresh_iretq;
			ltr id;
        }
	}
	
	void setNull(uint index) {
		m_tables[index].value = 0;
	}
	
	void setCode(uint index, bool conforming, ubyte dpl_, bool present) {
		m_tables[index].code = CodeSegmentDescriptor.init;

		with (m_tables[index].code) {
			c   = conforming;
			dpl = dpl_;
			p   = present;
			l   = true;
			d   = false;
		}
	}
	
	void setData(uint index, bool present, ubyte dpl) {
		m_tables[index].data     = DataSegmentDescriptor.init;
		m_tables[index].data.p   = present;
		m_tables[index].data.dpl = dpl;
	}
	
	void setSystem(uint index, uint limit, ulong base, SystemSegmentType segType, ubyte dpl_, bool present, bool available, bool granularity) {
		m_tables[index].systemLo     = SystemSegmentDescriptor.init;
		m_tables[index + 1].systemHi = SystemSegmentExtension.init;

		with (m_tables[index].systemLo) {
			baseLo    = (base & 0xFFFF);
			baseMidLo = (base >> 16) & 0xFF;
			baseMidHi = (base >> 24) & 0xFF;

			limitLo   = limit & 0xFFFF;
			limitHi   = (limit >> 16) & 0xF;

			type      = segType;
			dpl       = dpl_;
			p         = present;
			avl       = available;
			g         = granularity;
		}

		m_tables[index + 1].systemHi.baseHi = (base >> 32) & 0xFFFFFFFF;
	}
	
	void setTSS(uint index, ref TaskStateSegment tss) {
		m_tables[index].tss1     = TSSDescriptor1(tss);
		m_tables[index + 1].tss2 = TSSDescriptor2(tss);
	}
	
	private ushort setupTable() {
		ushort i;
		setNull(i++);
		
		// Kernel
		setCode(i++, false, 0, true);
		setData(i++, true, 0);
		
		// User
		setData(i++, true, 3);
		setCode(i++, true, 3, true);
		
		// User 32
		setData(i++, true, 3);
		
		m_tssId = i;
		setTSS(i, m_tss);
		i += 2;
		
		return i;
	}
}


private struct Base {
align(1):
    ushort limit;
    ulong base;
}

private struct CodeSegmentDescriptor {
@trusted: nothrow: @nogc:
align(1):
	ushort limit = 0xFFFF;
	ushort base = 0x0000;
	ubyte baseMid = 0x00;
	private ubyte flags1 = 0b11111101;
	private ubyte flags2 = 0b00000000;
	ubyte baseHigh = 0x00;

	mixin(bitfield!(flags1, "zero3", 2, "c", 1, "ones0", 2, "dpl", 2, "p", 1));
	mixin(bitfield!(flags2, "zero4", 5, "l", 1, "d", 1, "granularity", 1));
}

private struct DataSegmentDescriptor {
@trusted: nothrow: @nogc:
align(1):
	ushort limit = 0xFFFF;
	ushort base = 0x0000;
	ubyte baseMid = 0x00;
	private ubyte flags1 = 0b11110011;
	private ubyte flags2 = 0b11001111;
	ubyte baseHigh = 0x00;

	mixin(bitfield!(flags1, "zero4", 5, "dpl", 2, "p", 1));
}

private struct SystemSegmentDescriptor {
@trusted: nothrow: @nogc:
align(1):
	ushort limitLo;
	ushort baseLo;
	ubyte baseMidLo;
	private ubyte flags1;
	private ubyte flags2;
	ubyte baseMidHi;

	mixin(bitfield!(flags1, "type", 4, "zero0", 1, "dpl", 2, "p", 1));
	mixin(bitfield!(flags2, "limitHi", 4, "avl", 1, "zero1", 2, "g", 1));
}

private struct SystemSegmentExtension {
align(1):
	uint baseHi;
	private uint _reserved_0;
}

private union SegmentDescriptor {
align(1):
	DataSegmentDescriptor data;
	CodeSegmentDescriptor code;
	SystemSegmentDescriptor systemLo;
	SystemSegmentExtension systemHi;
	
	TSSDescriptor1 tss1;
	TSSDescriptor2 tss2;
	
	ulong value;
}

static assert(SegmentDescriptor.sizeof == ulong.sizeof);


private extern(C) void __refresh_iretq();