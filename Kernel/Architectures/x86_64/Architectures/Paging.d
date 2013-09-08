module Architectures.Paging;

import MemoryManager.Memory;
import MemoryManager.PhysMem;
import MemoryManager.PageAllocator;

import System.Collections.All;
import System.SystemException;

import Architectures.CPU;
import Architectures.x86_64.Core.IDT;


alias PageTableEntry!("primary") PTE;

enum AccessMode : uint {
	Read 			= 0,
	AllocOnAccess 	= 2,
	Global 			= 1,
	MapOnce			= 4,
	CopyOnWrite		= 8,
	PrivilegedGlob	= 16,
	PrivilegedExec	= 32,
	Segment			= 64,
	RootPageTable	= 128,
	Device			= 256,
	Delete			= 512,

	Writable		= 1 << 14,
	User			= 1 << 15,
	Executable		= 1 << 16,

	DefaultUser		= Writable | AllocOnAccess | User,
	DefaultKernel	= Writable | AllocOnAccess,
	
	AvailableMask	= Global | AllocOnAccess | MapOnce | CopyOnWrite | Writable | User | Executable,
}

template PageTableEntry(string T) {
	struct PageTableEntry {
		ulong pml;
		static if (T == "primary") {
			mixin(Bitfield!(pml,
				"Present", 		1,
				"ReadWrite", 	1,
				"User", 		1,
				"WriteThrough",	1,
				"CacheDisable",	1,
				"Accessed",		1,
				"Dirty",		1,
				"PAT",			1,
				"Global",		1,
				"Avl",			3,
				"Address",		40,
				"Available",	11,
				"NX",			1
			));
		} else static if (T == "secondary") {
			mixin(Bitfield!(pml,
				"Present", 		1,
				"ReadWrite", 	1,
				"User", 		1,
				"WriteThrough",	1,
				"CacheDisable",	1,
				"Accessed",		1,
				"Reserved",		1,
				"PageSize",		1,
				"Ignored",		1,
				"Avl",			3,
				"Address",		40,
				"Available",	11,
				"NX",			1
			));
		} else
			static assert(false);
		
		@property PhysicalAddress Location() {
			return cast(PhysicalAddress)(cast(ulong)Address << 12);
		}
		
		@property AccessMode Mode() {
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
		
		@property void Mode(AccessMode mode) {
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
}

template PageLevel(ubyte L) {
	struct PageLevel {
		alias L Level;

		static if (L == 1) {
			void* PhysicalAddress(uint index) {
				if (!Entries[index].Present)
					return null;
					
				return cast(void *)Entries[index].Location;
			}
			
			private PageTableEntry!("primary")[512] Entries;
		} else {
			PageLevel!(L - 1)* GetTable(uint index) {
				return Tables[index];
			}
			
			void SetTable(uint index, PageLevel!(L - 1)* address, bool usermode = false) {
				Entries[index].pml = cast(ulong)address;
				Entries[index].Present = 1;
				Entries[index].ReadWrite = 1;
				Entries[index].User = usermode;
				Tables[index] = address;
			}
			
			PageLevel!(L - 1)* GetOrCreateTable(uint index, bool usermode = false) {
				PageLevel!(L - 1)* ret = Tables[index];
				
				if (ret == null) {
					static if (L == 1)
						ret = cast(PageLevel!(L - 1) *)PageAllocator.AllocPage();
					else
						ret = cast(PageLevel!(L - 1) *)PageAllocator.AllocPage(2);
					*ret = (PageLevel!(L - 1)).init;
					SetTable(index, ret, usermode);
				}
				
				return ret;
			}
			
			private PageTableEntry!("secondary")[512] Entries;
			private PageLevel!(L - 1)*[512] Tables = null;
		}
	}
}

class Paging {
	public __gshared Paging KernelPaging;

	private PageLevel!(4)* root;
	private VirtualAddress regions = cast(VirtualAddress)0xFFF_0000_0000;

	
	this() {
		root = cast(PageLevel!(4) *)PageAllocator.AllocPage(2);
		*root = (PageLevel!(4)).init;
	}
	
	void Install() {
		ulong adr = cast(ulong)GetPhysicalAddress(cast(VirtualAddress)root);


		asm {
			mov RAX, adr;
			call _CPU_load_cr3;
		}
	}
	
	void AllocFrame(VirtualAddress address, bool user, bool writable) {
		PhysMem.AllocFrame(GetPage(address, user), user, writable);
	}

	void FreeFrame(VirtualAddress address) {
		PhysMem.FreeFrame(GetPage(address));
	}
	
	ubyte[] MapRegion(PhysicalAddress pAdd, ulong length) {
		ubyte[] result = MapRegion(pAdd, regions, length);
		regions += (length & ~0xFFFUL) + ((length & 0xFFF) ? 0x1000 : 0);
		return result;
	}

	ubyte[] MapRegion(PhysicalAddress pAdd, VirtualAddress vAdd, ulong length) {
		for (ulong i = 0; i < length; i += 0x1000) {
			auto pt = &GetPage(vAdd + i);

			pt.pml = 0;
			pt.Present = true;
			pt.ReadWrite = true;
			pt.Address = (cast(ulong)pAdd >> 12) + i;
		}
		
		int diff = cast(int)pAdd & 0xFFF;
		return vAdd[diff .. diff + length];
	}


private:
	PhysicalAddress GetPhysicalAddress(VirtualAddress address) {
		ulong add = cast(ulong)address;
	
		ushort[4] start;
		start[3] = (add >> 39) & 511; //PML4E
		start[2] = (add >> 30) & 511; //PDPTE
		start[1] = (add >> 21) & 511; //PDE
		start[0] = (add >> 12) & 511; //PTE
		
		PageLevel!(3)* pdpt;
		if (root.Entries[start[3]].Present)
			pdpt = root.Tables[start[3]];
		else
			return address;
			
		PageLevel!(2)* pd;
		if (pdpt.Entries[start[2]].Present)
			pd = pdpt.Tables[start[2]];
		else
			return address;
			
		PageLevel!(1)* pt;
		if (pd.Entries[start[1]].Present)
			pt = pd.Tables[start[1]];
		else
			return address;
			
		return pt.Entries[start[0]].Location;
	}
	
	ref PTE GetPage(VirtualAddress address, bool usermode = false) {
		ulong add = cast(ulong)address;
	
		ushort[4] start;
		start[3] = (add >> 39) & 511; //PML4E
		start[2] = (add >> 30) & 511; //PDPTE
		start[1] = (add >> 21) & 511; //PDE
		start[0] = (add >> 12) & 511; //PTE
		
		auto pdpt = root.GetOrCreateTable(start[3], usermode);
		auto pd = pdpt.GetOrCreateTable(start[2], usermode);
		auto pt = pd.GetOrCreateTable(start[1], usermode);
		
		return pt.Entries[start[0]];
	}


	void PageFaultHandler(InterruptStack *stack) {
		import Core.Log;
		Log.Print(" ==== Page Fault ====", 0x200);

		asm {
			cli;
			hlt;
		}
	}

	void GeneralProtectionFaultHandler(InterruptStack *stack) {
		import Core.Log;
		Log.Print(" ==== General Protection Fault ====", 0x200);

		asm {
			cli;
			hlt;
		}
	}
}
