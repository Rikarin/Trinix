/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module arch.amd64.tss;

import common.address;
import common.bitfield;


struct TaskStateSegment {
align(1):
    private uint _reserved_0;
	VAddr[3] rsp;
    private ulong _reserved_1;
    VAddr[7] ist;
    private ulong _reserved_2;
    private ushort _reserved_3;
	
	ushort ioPermBitMapOffset = ioBitmap.offsetof;
	align(4096) ubyte[1 << 16] ioBitmap;
	ubyte stopper = 0xFF;
}

struct TSSDescriptor1 {
align(1):
	ushort limit0 = 0x67;
	ushort base0;
	ubyte base16;

	private ubyte flags1;
	mixin(bitfield!(flags1, "type", 4, "res0", 1, "dpl", 2, "present", 1));

	private ubyte flags2;
	mixin(bitfield!(flags2, "limit16", 4, "available", 1, "res1", 2, "granularity", 1));

	ubyte base24;
	
	this(ref TaskStateSegment tss) {
		type      = 9;
		present   = 1;
		available = 1;

		ulong ptr = cast(ulong)&tss;
		base0     = ptr & 0xFFFF;
		base16    = (ptr >> 16) & 0xFF;
		base24    = (ptr >> 24) & 0xFF;
	}
}

struct TSSDescriptor2 {
align(1):
	uint base32;
	private uint _reserved_0;
	
	this(ref TaskStateSegment tss) {
		base32 = cast(ulong)(&tss) >> 0x20;
	}
}
