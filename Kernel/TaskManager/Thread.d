module TaskManager.Thread;

import SyscallManager.Resource;
import MemoryManager.Memory;
import TaskManager.Process;
import TaskManager.Task;


class Thread /*: Resource*/ {
package:
	ulong rsp, rbp, rip;
	ubyte state;
	Process parent;

	WaitUnion waitFor;
	byte[] userStack, kernelStack;

	union WaitUnion {
		ulong time;
		ubyte irq;
	}

public:
	enum Status {
		Zombie,
		Running,
		Sleeping,
		IRQWait
	}

	bool Runnable() { return true; } // todo

	/*this(uint a) { }
	this(ulong delegate(void* offset) ThreadEntry, void* data) {
		//super();

		parent = Task.CurrentProcess;
		kernelStack = new byte[0x1000];

		//userStack.address = 
		//userStack.size... todo
	}*/

//Syscalls
//	override bool Accesible() { return true; }
}