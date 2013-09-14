module MemoryManager.PhysMem;

import System.SystemException;
import System.Collections.All;

import Core.Log;
import Architectures.Paging;
import MemoryManager.Memory;


class PhysMem {
static:
	private __gshared BitArray frames;
	private __gshared ulong pointer;


	void Init() {
		frames = new BitArray(0x1_000_000, false);
		pointer = 0;

		Paging.KernelPaging = new Paging();
		for (ulong i = 0xC00_0000; i < 0xCFF_0000; i += 0x1000)
			Paging.KernelPaging.AllocFrame(cast(VirtualAddress)i, false, true);

		Paging.KernelPaging.Install();

		new testik[1];
		asm {hlt;}

		pointer = ~1UL;
		Log.Result(true);
	}

	void AllocFrame(ref PTE page, bool user, bool writable) {
		if (page.Present)
			return;//throw new MemoryException();

		long index = pointer != ~1UL ? pointer++ : frames.FirstFreeBit();
		frames[index] = true;

		page.Present = true;
		page.Address = index;
		page.User = user;
		page.ReadWrite = writable;
	}
	
	void FreeFrame(ref PTE page) {
		if (!page.Present)
			return;

		frames[page.Address] = false;
		page.Present = false;
	}
}
class testik {
int a;
this() {a = 5;}

}