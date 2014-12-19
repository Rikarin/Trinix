/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 * 
 * TODO:
 *      o Add free for mapped regions
 */

module MemoryManager.Paging;

import Core;
import Library;
import TaskManager;
import Architecture;
import MemoryManager;
import ObjectManager;


alias PageTableEntry!"primary" PTE;


enum AccessMode : uint {
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

	/* I dont know what Executable really is but its works with it... */
	DefaultKernel   = Writable | AllocOnAccess | Executable,
	DefaultUser	    = Writable | AllocOnAccess | Executable | User,
	AvailableMask   = Writable | AllocOnAccess | Executable | User | MapOnce | CopyOnWrite | Global
}


struct PageTableEntry(string T) {
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
	
	@property void* Location() {
		return cast(void *)(Address << 12);
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


struct PageLevel(ubyte L) {
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
		
		PageLevel!(L - 1)* GetOrCreateTable(uint index) {
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


final class Paging {
	enum PageSize = 0x1000;

	private PageLevel!4* _root;
	private void* _regions = cast(void *)0xFFFFFFFFE0000000;

	this() {
		_root = new PageLevel!4;
	}
	
	this(Paging other) {
		this();

		foreach (i; 0 .. 512) {                         /* PML4 */
			if (other._root.Tables[i]) {
				foreach (j; 0 .. 512) {                 /* PDPT */
					if (other._root.Tables[i].Tables[j]) {
						foreach (k; 0 .. 512) {         /* PD */
							if (other._root.Tables[i].Tables[j].Tables[k]) {
								foreach (m; 0 .. 512) { /* PT */
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
	
	~this() {
		foreach (i; 0 .. 512) {                                             /* PML4 */
			if (_root.Tables[i]) {
				foreach (j; 0 .. 512) {                                     /* PDPT */
					if (_root.Tables[i].Tables[j]) {
						foreach (k; 0 .. 512) {                             /* PD */
							if (_root.Tables[i].Tables[j].Tables[k])
								delete _root.Tables[i].Tables[j].Tables[k]; /* PT */
						}
						delete _root.Tables[i].Tables[j];
					}
				}
				delete _root.Tables[i];
			}
		}
		delete _root;
	}

	void Install() {
		void* addr = GetPhysicalAddress(cast(void *)_root);

		asm {
			"mov CR3, %0" : : "r"(addr);
		}
	}
	
	void AllocFrame(void* address, AccessMode mode) {
		PhysicalMemory.AllocFrame(GetPage(address), mode);
	}
	
	void FreeFrame(void* address) {
		PhysicalMemory.FreeFrame(GetPage(address));
	}
	
	ubyte[] MapRegion(void* pAdd, ulong length) {
		ubyte[] result = MapRegion(pAdd, _regions, length);
		_regions += (length & ~0xFFFUL) + ((length & 0xFFF) ? 0x1000 : 0);
		return result;
	}
	
	ubyte[] MapRegion(void* pAdd, void* vAdd, ulong length) {
		for (ulong i = 0; i < length; i += 0x1000) {
			auto pt = &GetPage(vAdd + i);
			
			pt.Present = true;
			pt.ReadWrite = true;
			pt.User = true;
			pt.Address = ((cast(ulong)pAdd + i) >> 12);
		}
		
		int diff = cast(int)pAdd & 0xFFF;
		return (cast(ubyte *)vAdd)[diff .. diff + length];
	}

	ref PTE GetPage(void* address) {
		ulong add = cast(ulong)address;
		
		ushort[4] start;
		start[3] = (add >> 39) & 511; /* PML4E */
		start[2] = (add >> 30) & 511; /* PDPTE */
		start[1] = (add >> 21) & 511; /* PDE */
		start[0] = (add >> 12) & 511; /* PTE */

		auto pdpt = _root.GetOrCreateTable(start[3]);
		auto pd = pdpt.GetOrCreateTable(start[2]);
		auto pt = pd.GetOrCreateTable(start[1]);
		
		return pt.Entries[start[0]];
	}

	void* GetPhysicalAddress(void* address) {
		ulong add = cast(ulong)address;
		
		ushort[4] start;
		start[3] = (add >> 39) & 511; /* PML4E */
		start[2] = (add >> 30) & 511; /* PDPTE */
		start[1] = (add >> 21) & 511; /* PDE */
		start[0] = (add >> 12) & 511; /* PTE */
		
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

        debug {
    		Log(`===> Spadlo to -.-"`);
            Log("IRQ = %16x | RIP = %16x", stack.IntNumber, stack.RIP);
            Log("RAX = %16x | RBX = %16x", stack.RAX, stack.RBX);
            Log("RCX = %16x | RDX = %16x", stack.RCX, stack.RDX);
            Log("RDI = %16x | RSI = %16x", stack.RDI, stack.RSI);
            Log("RSP = %16x | RBP = %16x", stack.RSP, stack.RBP);
            Log(" R8 = %16x |  R9 = %16x", stack.R8, stack.R9);
            Log("R10 = %16x | R11 = %16x", stack.R10, stack.R11);
            Log("R12 = %16x | R13 = %16x", stack.R12, stack.R13);
            Log("R14 = %16x | R15 = %16x", stack.R14, stack.R15);
            Log(" CS = %16x |  SS = %16x", stack.CS, stack.SS);
    		
    		ulong cr2;
    		asm {
    			"mov RAX, CR2" : "=a"(cr2);
    		}
    		
    		Log(" CR2 = %16x", cr2);
            Log("Flags: %16x", stack.Flags);
        }

        //TODO: what to do with this?
		asm {
			"cli";
			"hlt";
		}
	}
}