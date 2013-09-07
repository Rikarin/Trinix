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
	Process parent;

	WaitUnion waitFor;
	byte* userStack, kernelStack;

	union WaitUnion {
		ulong time;
		ubyte irq;
	}

	this() { /*super(0, null);*/ }

public:
	enum State : ubyte {
		Zombie,
		Running,
		Waiting,
	}

	this(void function(void* offset) ThreadEntry, void* data) {
		//super(0, null);
		Exec(cast(ulong)ThreadEntry, data);
	}


	private void Exec(ulong offset, void* data) {
		parent = Task.CurrentProcess;
		parent.threads.Add(&this);

		kernelStack = (new byte[STACK_SIZE]).ptr;
		state = State.Running;

		rbp = rsp = cast(ulong)kernelStack;
		rip = offset;

		//userStack.ptr = process.heap.alloc..;

		Task.Threads.Add(this);
	}

	static void run() { 
		while (true) { }
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
	//override bool Accesible() { return true; }
}