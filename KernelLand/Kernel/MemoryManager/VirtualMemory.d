module MemoryManager.VirtualMemory;

import Core;
import MemoryManager;
import ObjectManager;


abstract final class VirtualMemory : IStaticModule {
	private __gshared void* function(long size) _malloc = &TmpAlloc;
	private __gshared void function(void* ptr) _free;

	__gshared Paging KernelPaging;
	__gshared Heap KernelHeap;

	static bool Initialize() {
		Log.WriteJSON("module", "{");
		Log.WriteJSON("name", "Heap");
		Log.WriteJSON("type", "Initialize");
		KernelHeap = new Heap(cast(ulong)PhysicalMemory.AllocPage(), Heap.MinSize, Heap.CalculateIndexSize(Heap.MinSize));
		Log.WriteJSON("value", "True");
		Log.WriteJSON("}");

		return true;
	}

	static bool Install() {
		Log.WriteJSON("module", "{");
		Log.WriteJSON("name", "Heap");
		Log.WriteJSON("type", "Install");

		_malloc = function(long size) {
			return KernelHeap.Alloc(size);
		};

		_free = function(void* ptr) {
			KernelHeap.Free(ptr);
		};

		Log.WriteJSON("value", "True");
		Log.WriteJSON("}");
		return true;
	}


	private static void* TmpAlloc(long size) {
		return PhysicalMemory.AllocPage(size / 0x1000);
	}
}


extern(C) void* malloc(long size, int ba) {
	void* ret = VirtualMemory._malloc(size);
	//Log.WriteJSON("MemoryAlloc", "{", "size", size, "ba", ba, "address", cast(ulong)ret, "}");
	return ret;
}


extern(C) void free(void* ptr) {
	//Log.WriteJSON("MemoryFree", cast(ulong)ptr);

	VirtualMemory._free(ptr);
}