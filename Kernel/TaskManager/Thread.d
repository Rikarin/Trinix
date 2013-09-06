module TaskManager.Thread;

import Architectures.Core;
import SyscallManager.Resource;
import MemoryManager.Memory;
import TaskManager.Process;
import TaskManager.Task;


class Thread : Resource {
package:
	static const auto STACK_SIZE = 0x1000;

	ulong rsp, rbp, rip;
	State state;
	Process parent;

	WaitUnion waitFor;
	byte* userStack, kernelStack;

	union WaitUnion {
		ulong time;
		ubyte irq;
	}

	this() { super(0, null); }

public:
	enum State : ubyte {
		Zombie,
		Running,
		Waiting,
	}


	this(ulong delegate(void* offset) ThreadEntry, void* data) {
		super(0, null);

		parent = Task.CurrentProcess;
		kernelStack = (new byte[STACK_SIZE]).ptr;

		//userStack.ptr = process.heap.alloc..;
	}

	bool Valid(State state) {
		//todo pridat to ze ak time,signal alebo irq prislo tak aby to prebudilo vlakno
		if (state == this.state && parent.state != Process.State.Stopped)
			return true;
		return false;
	}

	void SetKernelStack() {
		TSS.Table.RSP0 = kernelStack + STACK_SIZE;
	}



//Syscalls
	override bool Accesible() { return true; }
}