module MemoryManager.Paging;

import Library;
import TaskManager;
import Architecture;
import MemoryManager;
import ObjectManager;


alias PageTableEntry!"primary" PTE;


public enum AccessMode : uint {
	Read            = 0,
	AllocOnAccess   = 2,
	Global          = 1,
	MapOnce         = 4,
	CopyOnWrite	    = 8,
	PrivilegedGlob  = 16,
	PrivilegedExec  = 32,
	Segment	        = 64,
	RootPageTable   = 128,
	Device          = 256,
	Delete          = 512,
	
	Writable        = 1 << 14,
	User            = 1 << 15,
	Executable      = 1 << 16,

	// I dont know what Executable really is but its works with it...
	DefaultKernel   = Writable | AllocOnAccess | Executable,
	DefaultUser	    = Writable | AllocOnAccess | Executable | User,
	AvailableMask   = Writable | AllocOnAccess | Executable | User | MapOnce | CopyOnWrite | Global
}


public struct PageTableEntry(string T) {
align(1):
	private ulong pml;

	static if (T == "primary") {
		mixin(Bitfield!(pml,
		                "Present", 1,
		                "ReadWrite", 1,
		                "User", 1,
		                "WriteThrough", 1,
		                "CacheDisable", 1,
		                "Accessed", 1,
		                "Dirty", 1,
		                "PAT", 1,
		                "Global", 1,
		                "Avl", 3,
		                "Address", 40,
		                "Available", 11,
		                "NX", 1
		                ));
	} else static if (T == "secondary") {
		mixin(Bitfield!(pml,
		                "Present", 1,
		                "ReadWrite", 1,
		                "User", 1,
		                "WriteThrough", 1,
		                "CacheDisable", 1,
		                "Accessed", 1,
		                "Reserved", 1,
		                "PageSize", 1,
		                "Ignored", 1,
		                "Avl", 3,
		                "Address", 40,
		                "Available", 11,
		                "NX", 1
		                ));
	} else
		static assert(false);
	
	@property public void* Location() {
		return cast(void *)(Address << 12);
	}
	
	@property public AccessMode Mode() {
		AccessMode mode;
		
		if (Present) {
			if (ReadWrite)
				mode |= AccessMode.Writable;
			if (User)
				mode |= AccessMode.User;
			if (!NX)
				mode |= AccessMode.Executable;
			
			mode |= Available;
		}
		return mode;
	}
	
	@property public void Mode(AccessMode mode) {
		Present = 1;
		Available = mode & AccessMode.AvailableMask;
		
		if (mode & AccessMode.Writable)
			ReadWrite = 1;
		else
			ReadWrite = 0;
		
		if (mode & AccessMode.User)
			User = 1;
		else
			User = 0;
		
		if (mode & AccessMode.Executable)
			NX = 0;
		else
			NX = 1;
		
		static if (T == "primary") {
			if (mode & AccessMode.Device)
				CacheDisable = 1;
		}
	}
}


public struct PageLevel(ubyte L) {
align(1):
	alias L Level;
	
	static if (L == 1) {
		void* PhysicalAddress(uint index) {
			if (!Entries[index].Present)
				return null;
			
			return cast(void *)Entries[index].Location;
		}
		
		private PageTableEntry!"primary"[512] Entries;
	} else {
		PageLevel!(L - 1)* GetTable(uint index) {
			return Tables[index];
		}
		
		private void SetTable(uint index, PageLevel!(L - 1)* address) {
			Entries[index].Address = cast(ulong)VirtualMemory.KernelPaging.GetPhysicalAddress(cast(void *)address)  >> 12;
			Entries[index].Mode = AccessMode.DefaultUser;
			Tables[index] = address;
		}
		
		public PageLevel!(L - 1)* GetOrCreateTable(uint index) {
			PageLevel!(L - 1)* ret = Tables[index];
			
			if (!ret) {
				static if (L == 1)
					ret = new PageLevel!(L - 1);
				else
					ret = new PageLevel!(L - 1);
				SetTable(index, ret);
			}
			
			return ret;
		}
		
		private PageTableEntry!"secondary"[512] Entries;
		private PageLevel!(L - 1)*[512] Tables;
	}
}


public final class Paging {
	public enum PageSize = 0x1000;

	private PageLevel!4* _root;
	//private void* _regions = cast(void *)0xFFFFFFFFE0000000;

	public this() {
		_root = new PageLevel!4;
	}
	
	public this(Paging other) {
		this();

		foreach (i; 0 .. 512) { //PML4
			if (other._root.Tables[i]) {
				foreach (j; 0 .. 512) { //PDPT
					if (other._root.Tables[i].Tables[j]) {
						foreach (k; 0 .. 512) { //PD
							if (other._root.Tables[i].Tables[j].Tables[k]) {
								foreach (m; 0 .. 512) { //PT
									PTE page = other._root.Tables[i].Tables[j].Tables[k].Entries[m];
									if (page.Present) {
										ulong address = (cast(ulong)i << 39) | (j << 30) | (k << 21) | (m << 12);

										PTE pte = GetPage(cast(void *)address);
										pte.Address = address;
										pte.Mode = page.Mode;
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
	public ~this() {
		foreach (i; 0 .. 512) { //PML4
			if (_root.Tables[i]) {
				foreach (j; 0 .. 512) { //PDPT
					if (_root.Tables[i].Tables[j]) {
						foreach (k; 0 .. 512) { //PD
							if (_root.Tables[i].Tables[j].Tables[k])
								delete _root.Tables[i].Tables[j].Tables[k]; //PT
						}
						delete _root.Tables[i].Tables[j];
					}
				}
				delete _root.Tables[i];
			}
		}
		delete _root;
	}

	public void Install() {
		void* addr = GetPhysicalAddress(cast(void *)_root);

		asm {
			"mov CR3, %0" : : "r"(addr);
		}
	}
	
	public void AllocFrame(void* address, AccessMode mode) {
		PhysicalMemory.AllocFrame(GetPage(address), mode);
	}
	
	public void FreeFrame(void* address) {
		PhysicalMemory.FreeFrame(GetPage(address));
	}
	
	/*ubyte[] MapRegion(void* pAdd, ulong length)
	{
		ubyte[] result = MapRegion(pAdd, regions, length);
		regions += (length & ~0xFFFUL) + ((length & 0xFFF) ? 0x1000 : 0);
		return result;
	}
	
	ubyte[] MapRegion(void* pAdd, void* vAdd, ulong length)
	{
		for (ulong i = 0; i < length; i += 0x1000)
		{
			auto pt = &GetPage(vAdd + i);
			
			pt.Present = true;
			pt.ReadWrite = true;
			pt.User = true;
			pt.Address = ((cast(ulong)pAdd + i) >> 12);
		}
		
		int diff = cast(int)pAdd & 0xFFF;
		return (cast(ubyte *)vAdd)[diff .. diff + length];
	}*/

	public ref PTE GetPage(void* address) {
		ulong add = cast(ulong)address;
		
		ushort[4] start;
		start[3] = (add >> 39) & 511; //PML4E
		start[2] = (add >> 30) & 511; //PDPTE
		start[1] = (add >> 21) & 511; //PDE
		start[0] = (add >> 12) & 511; //PTE

		auto pdpt = _root.GetOrCreateTable(start[3]);
		auto pd = pdpt.GetOrCreateTable(start[2]);
		auto pt = pd.GetOrCreateTable(start[1]);
		
		return pt.Entries[start[0]];
	}

	public void* GetPhysicalAddress(void* address) {
		ulong add = cast(ulong)address;
		
		ushort[4] start;
		start[3] = (add >> 39) & 511; //PML4E
		start[2] = (add >> 30) & 511; //PDPTE
		start[1] = (add >> 21) & 511; //PDE
		start[0] = (add >> 12) & 511; //PTE
		
		PageLevel!3* pdpt;
		if (_root.Entries[start[3]].Present)
			pdpt = _root.Tables[start[3]];
		else
			return cast(void *)(add - cast(ulong)LinkerScript.KernelBase);
		
		PageLevel!2* pd;
		if (pdpt.Entries[start[2]].Present)
			pd = pdpt.Tables[start[2]];
		else
			return cast(void *)(add - cast(ulong)LinkerScript.KernelBase);
		
		PageLevel!1* pt;
		if (pd.Entries[start[1]].Present)
			pt = pd.Tables[start[1]];
		else
			return cast(void *)(add - cast(ulong)LinkerScript.KernelBase);
		
		return pt.Entries[start[0]].Location;
	}

	static void PageFaultHandler(ref InterruptStack stack) {
		if (stack.RIP == Thread.ThreadReturn)
			Task.CurrentThread.Exit(stack.RAX);


		//TODO: testing purpose only...
		import Core;
		Log.WriteLine("Error!", `Paging sa dojebal -.-"`);
		Log.WriteJSON("interrupt", "{");
		Log.WriteJSON("irq", stack.IntNumber);
		Log.WriteJSON("rax", stack.RAX);
		Log.WriteJSON("rbx", stack.RBX);
		Log.WriteJSON("rcx", stack.RCX);
		Log.WriteJSON("rdx", stack.RDX);
		Log.WriteJSON("rip", stack.RIP);
		Log.WriteJSON("rbp", stack.RBP);
		Log.WriteJSON("rsp", stack.RSP);
		Log.WriteJSON("cs", stack.CS);
		Log.WriteJSON("ss", stack.SS);
		Log.WriteJSON("call track", *(cast(ulong *)stack.RBP + 8));
		
		ulong cr2;
		asm {
			"mov RAX, CR2" : "=a"(cr2);
		}
		
		Log.WriteJSON("cr2", cr2);
		asm {
			"cli";
			"hlt";
		}
	}
}