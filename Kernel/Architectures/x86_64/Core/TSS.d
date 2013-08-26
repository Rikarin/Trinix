module Architectures.x86_64.Core.TSS;

import Architectures.CPU;
import Architectures.x86_64.Core.GDT;
import Architectures.x86_64.Core.Descriptor;

import MemoryManager.Memory;
import MemoryManager.PageAllocator;


class TSS
{
	private __gshared ushort tssBase = 0x30;
	private __gshared TaskStateSegment*[256] Segments;
	
static:
	bool Init() { return true; }

	bool Install() {
		TaskStateSegment* tss = cast(TaskStateSegment *)PageAllocator.AllocPage();
		*tss = TaskStateSegment.init;
		Segments[CPU.Identifier] = tss;
		GDT.Tables[CPU.Identifier].SetSystemSegment((tssBase >> 3), 0x67, cast(ulong)tss, SystemSegmentType.AvailableTSS, 0, true, false, false);
		
		asm {
			ltr tssBase;
		}
		return true;
	}
	
	struct TaskStateSegment {
	align(1):
	private:
		uint reserved0;

		void* rsp0;
		void* rsp1;
		void* rsp2;

		ulong reserved1;

		void*[7] ist;

		ulong reserved2;
		ushort reserved3;

		ushort ioMap;

	public:
		@property void RSP0(void* stackPointer) {
			rsp0 = stackPointer;
		}
		
		@property void* RSP0() {
			return rsp0;
		}

		void IST(uint index, void* ptr) {
			ist[index] = ptr;
		}
		
		void* IST(uint index) {
			return ist[index];
		}
	}
	
	@property TaskStateSegment* Table() {
		return Segments[CPU.Identifier];
	}
}
