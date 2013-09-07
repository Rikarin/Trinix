module TaskManager.Thread;

import Architectures.Core;
import Architectures.CPU;
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
		userStack   = (new byte[STACK_SIZE]).ptr; //process.heap.alloc..;
		state = State.Running;

		ulong* stack = cast(ulong *)kernelStack + STACK_SIZE;
		rbp = cast(ulong)stack;
		stack--;
		*stack = cast(ulong)offset;
		stack--;
		*stack = cast(ulong)data;
		stack--;
		*stack = cast(ulong)userStack;
		stack--;
		*stack = 0;

		rsp = cast(ulong)stack;
		rip = cast(ulong)&run;

		Task.Threads.Add(this);
	}

	static void run() {
		ulong* stack;
		void* data;
		ulong enter;

		asm {
			mov RAX, [RBP + 16];
			mov stack, RAX;

			mov RAX, [RBP + 24];
			mov data, RAX;

			mov RAX, [RBP + 32];
			mov enter, RAX;
		}

		stack += STACK_SIZE;
		stack--;
		*stack = cast(ulong)data;
		stack--;
		*stack = 0;

		asm {
			xor RAX, RAX;
			mov AX, 0x1B;
			mov DS, AX;
			mov ES, AX;
			mov FS, AX;
			mov GS, AX;
			mov SS, AX;

			push RAX;
			push stack;

			pushfq;
			pop RAX;
			or RAX, 0x200UL;
			push RAX;

			push 0x23UL;
			push enter;
			jmp _CPU_iretq;
		}
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