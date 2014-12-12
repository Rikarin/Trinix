module Architectures.x86_64.Core.TSS;

import Architecture;
import MemoryManager;
import ObjectManager;
import Architectures.x86_64.Core;


struct TaskStateSegment {
align(1):
	private uint _reserved0;
	
	private void* _rsp0;
	private void* _rsp1;
	private void* _rsp2;
	
	private ulong _reserved1;
	
	private void*[7] _ist;
	
	private ulong _reserved2;
	private ushort _reserved3;
	
	private ushort _ioMap;
	
	@property void RSP0(void* stackPointer) {
		_rsp0 = stackPointer;
	}
	
	@property void* RSP0() {
		return _rsp0;
	}
	
	void IST(uint index, void* ptr) {
		_ist[index] = ptr;
	}
	
	void* IST(uint index) {
		return _ist[index];
	}
}


abstract final class TSS : IStaticModule {
	private enum TSSBase = 0x28;
	private __gshared TaskStateSegment*[256] _segments;

	@property static TaskStateSegment* Table() {
		return _segments[CPU.Identifier];
	}

	static bool Initialize() {
		_segments[CPU.Identifier] = new TaskStateSegment;
		return true;
	}

	static bool Install() {
		GDT.Table.SetSystemSegment((TSSBase >> 3), TaskStateSegment.sizeof, cast(ulong)_segments[CPU.Identifier], SystemSegmentType.AvailableTSS, 0, true, false, false);

		asm {
			"ltr AX" : : "a"(TSSBase);
		}
		return true;
	}
}