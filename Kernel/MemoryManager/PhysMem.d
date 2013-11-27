module MemoryManager.PhysMem;

import Core;
import Architectures;
import MemoryManager;

import System;
import System.Collections;


class PhysMem {
static:
	private __gshared BitArray frames;
	private __gshared ulong pointer;


	void Init() {
		frames = new BitArray(0x1_000_000, false);

		Paging.KernelPaging = new Paging();
		for (ulong i = 0xC00_0000; i < 0xFFF_0000; i += 0x1000)
			Paging.KernelPaging.AllocFrame(cast(VirtualAddress)i, true, true); //true for test task manager

		Paging.KernelPaging.Install();

		pointer = ~0UL;
		Log.Result(true);
	}

	void AllocFrame(ref PTE page, bool user, bool writable) {
		if (page.Present)
			return;//throw new MemoryException();

		long index     = pointer != ~0UL ? pointer++ : frames.FirstFreeBit();
		frames[index]  = true;

		import Core, System;
		Log.Print("addr: " ~ Convert.ToString(cast(ulong)index, 16));

		page.Present   = true;
		page.Address   = index;
		page.User      = user;
		page.ReadWrite = writable;
	}
	
	void FreeFrame(ref PTE page) {
		if (!page.Present)
			return;

		frames[page.Address] = false;
		page.Present = false;
	}
}