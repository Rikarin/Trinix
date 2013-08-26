module MemoryManager.PhysMem;

import System.SystemException;
import System.Collections.All;

import Core.Log;
import Architectures.Paging;
import MemoryManager.Memory;


class PhysMem {
static:
	private __gshared BitArray frames;
	
private __gshared long add;

	void Init() {
	//	frames = new BitArray(0x2_000_000, false);
add = 0;
		Paging.KernelPaging = new Paging();
		for (ulong i = 0; i < 0x4_000_000; i += 0x1000)
			Paging.KernelPaging.AllocFrame(cast(VirtualAddress)i, false, true);
		Paging.KernelPaging.Install();

		for (ulong i = 0x4_000_000; i < 0x30_000_000; i += 0x1000)
			Paging.KernelPaging.AllocFrame(cast(VirtualAddress)i, false, true);

		Log.Result(true);
	}

	void AllocFrame(ref PTE page, bool user, bool writable) {
		if (page.Present)
			return;//throw new MemoryException();

		long index = add++;//frames.FirstFreeBit();

		/*import System.Convert;
		import Core.Log;
		Log.PrintSP("\nid: " ~ Convert.ToString(index));
*/

	//	frames[index] = true;

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
