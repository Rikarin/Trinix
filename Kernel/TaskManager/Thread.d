module TaskManager.Thread;

import Architectures.Core;
import Architectures.CPU;
import SyscallManager.Resource;
import MemoryManager.Memory;
import TaskManager.Process;
import TaskManager.Task;
import System.Collections.Generic.All;
import System.DateTime;


class Thread /*: Resource*/ {
package:
	static const auto STACK_SIZE = 0x1000;

	ulong id; //unique ID for each thread
	ulong rsp, rbp, rip;
	long retval;
	State state;
	Process parent;

	WaitUnion waitFor;
	byte* userStack, kernelStack;

	union WaitUnion {
		DateTime time;
		ubyte irq;
	}

	this() { /*super(0, null);*/ }


public:
	enum State : ubyte {
		Zombie,
		Starting,
		Running,
		Waiting,    //time wait
		Sleeping,   //wait for driver resume
	}

	@property ulong ID() { return id; }

	this(void function() ThreadEntry, void* data = null) {
		//super(0, null);
		
		parent = Task.CurrentProcess;
		parent.threads.Add(this);

		kernelStack = (new byte[STACK_SIZE]).ptr;
		userStack   = (new byte[STACK_SIZE]).ptr; //process.heap.alloc..;
		state = State.Starting;

		//Set user stack
		ulong* ustack = cast(ulong *)userStack + STACK_SIZE;
		ustack--;
		*ustack = cast(ulong)data;
		ustack--;

		//Set kernel stack
		ulong* stack = cast(ulong *)kernelStack + STACK_SIZE;
		rbp = cast(ulong)stack;
		stack--;
		*stack = cast(ulong)ThreadEntry;
		stack--;
		*stack = cast(ulong)ustack;
		stack--;
		*stack = 0;

		rsp = cast(ulong)stack;
		rip = cast(ulong)&run;

		Task.Threads.Add(this);
	}

	static void run() {
		ulong stack;
		ulong enter;

		asm {
			mov RAX, [RBP + 16];
			mov stack, RAX;

			mov RAX, [RBP + 24];
			mov enter, RAX;
		}

		asm {
			xor RAX, RAX;
			mov AX, 0x10;//0x23; //testig
			mov DS, AX;
			mov ES, AX;
			mov FS, AX;
			mov GS, AX;

			push RAX;
			push stack;

			pushfq;
			pop RAX;
			or RAX, 0x200UL;
			push RAX;

			push 0x08UL; //0x1BUL; //testing
			push enter;
			jmp _CPU_iretq;
		}
	}

	bool Valid(State state) {
		if (state == this.state && parent.state != Process.State.Stopped)
			return true;
		return false;
	}

	void SetKernelStack() {
		TSS.Table.RSP0 = kernelStack + STACK_SIZE;
	}

	void Sleep(List!Thread queue) {
		state = State.Sleeping;
		queue.Add(this);
	}

	void WaitTime(DateTime time) {
		state = State.Waiting;
		waitFor.time = time;
	}

	void Start() {
		state = State.Running;
	}


//Syscalls
	//override bool Accesible() { return true; }
}