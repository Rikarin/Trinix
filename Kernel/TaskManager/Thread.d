module TaskManager.Thread;

import Architectures.Core;
import SyscallManager.Resource;
import MemoryManager.Memory;
import TaskManager.Process;
import TaskManager.Task;


class Thread /*: Resource*/ {
package:
	static const auto STACK_SIZE = 0x1000;

	ulong rsp, rbp, rip;
	State state;
	uint mask;
	Process parent;

	WaitUnion waitFor;
	byte* userStack, kernelStack;

	union WaitUnion {
		ulong time;
		ubyte irq;
	}

	this() { }

public:
	enum State : ubyte {
		Zombie,
		Running,
		Waiting,
	}


	//this(uint a) { }
	this(ulong delegate(void* offset) ThreadEntry, void* data) {
		//super();

		parent = Task.CurrentProcess;
		kernelStack = (new byte[STACK_SIZE]).ptr;

		//userStack.ptr = process.heap.alloc..;
	}

	bool Valid(State state) {
		//todo pridat to ze ak time,signal alebo irq prislo tak aby to prebudilo vlakno
		if (state == this.state)
			return true;
		return false;
	}

	void SetKernelStack() {
		TSS.Table.RSP0 = kernelStack + STACK_SIZE;
	}



//Syscalls
//	override bool Accesible() { return true; }
}