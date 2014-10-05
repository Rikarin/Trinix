module MemoryManager.PhysicalMemory;

import Library;
import Architecture;
import MemoryManager;


public abstract final class PhysicalMemory {
	private __gshared ulong _startMemory;
	private __gshared BitArray _frames;

	// Used in Multiboot info for shifting addr to the end of the modules
	@property public static ulong MemoryStart() {
		return _startMemory;
	}

	@property public static void MemoryStart(ulong addr) {
		_startMemory = addr;
	}

	public static bool Initialize() {
		_frames = new BitArray(0x10_000, false); //Hack: treba zvetsit paging tabulky v Boot.s lebo sa kernel potom neviem premapovat pre nedostatok pamete :/

		VirtualMemory.KernelPaging = new Paging();
		for (ulong i = 0xFFFFFFFF80000000; i < 0xFFFFFFFF8A000000; i += 0x1000)
			VirtualMemory.KernelPaging.AllocFrame(cast(void *)i, AccessMode.DefaultKernel);

		return true;
	}

	public static bool Install() {
		VirtualMemory.KernelPaging.Install();
		return true;
	}

	// Used by Paging
	package static void AllocFrame(ref PTE page, AccessMode mode) {
		if (page.Present)
			return;
		
		long index = _frames.FirstFreeBit();
		_frames[index] = true;
		page.Address = index;
		page.Mode = mode;
	}

	// Used by Paging
	package static void FreeFrame(ref PTE page) {
		if (!page.Present)
			return;
		
		_frames[page.Address] = false;
		page.Present = false;
	}

	public static void* AllocPage(long count = 1) {
		if (count < 1)
			count = 1;
			
		void* ret = LinkerScript.KernelEnd + _startMemory;
		_startMemory += 0x1000 * count;

		return ret;
	}
}