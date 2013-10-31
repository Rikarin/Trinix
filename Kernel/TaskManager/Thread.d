module TaskManager.Thread;

import Architectures.CPU;
import Architectures.Core;
import Architectures.Port;

import TaskManager.Task;
import TaskManager.Process;

import MemoryManager.Memory;
import SyscallManager.Resource;

import System.IFace;
import System.DateTime;
import SyscallManager.Syscall;
import System.Collections.Generic.List;


class Thread : Resource {
package:
	/** 0x1000 bytes to ulong */
	enum STACK_SIZE = 0x1000 / 8;

	/** Unique ID for each thread */
	ulong id;
	ulong rsp, rbp, rip;
	State state;
	Process parent;

	WaitUnion waitFor;
	ulong* userStack, kernelStack, syscallStack;

	union WaitUnion {
		DateTime time;
		ubyte irq;
	}

	this() { super(0, null); }


public:
	enum ThreadReturn = 0xFFFFFFFF_FFFFB00F;
	enum State : ubyte {
		Zombie,
		Starting,
		Running,
		Waiting,    //time wait
		Sleeping,   //wait for driver resume
	}

	@property ulong ID() { return id; }

	this(void function(ulong*) ThreadEntry, void* data = null, Process parent = Task.CurrentProcess) {
		super(0, null);

		parent.threads.Add(this);
		id = Task.NewTID();
		this.parent  = parent;
		kernelStack  = (new ulong[STACK_SIZE]).ptr;
		syscallStack = (new ulong[STACK_SIZE]).ptr;
		userStack    = (new ulong[STACK_SIZE]).ptr; //process.heap.alloc..;
		state        = State.Running;

		//Set user stack
		ulong* ustack = userStack + STACK_SIZE;
		*ustack = ThreadReturn;

		//Set kernel stack
		ulong* kstack = kernelStack + STACK_SIZE;
		rbp = cast(ulong)kstack;
		kstack--;
		*kstack = cast(ulong)data;
		kstack--;
		*kstack = cast(ulong)ThreadEntry;
		kstack--;
		*kstack = cast(ulong)ustack;

		//Set syscallStack
		syscallStack[1] = cast(ulong)kernelStack + STACK_SIZE / 2;

		rsp = cast(ulong)kstack;
		rip = cast(ulong)&run;

		Task.Threads.Add(this);
	}

	static void run() {
		asm {
			naked;
			cli;
			pop RBX; //User stack
			pop RCX; //ThreadEntry
			pop RDI; //data

			xor RAX, RAX;
			mov AX, 0x1B;
			mov DS, AX;
			mov ES, AX;
			mov FS, AX;
			mov GS, AX;

			push RAX;
			push RBX;

			pushfq;
			pop RAX;
			or RAX, 0x200UL;
			push RAX;

			push 0x23UL;
			push RCX;
			jmp _CPU_iretq;
		}
	}

	bool Valid(State value) {
		if (state == value)// && parent.state != Process.State.Stopped
			return true;
		
		return false;
	}

	void SetKernelStack() {
		TSS.Table.RSP0 = kernelStack + STACK_SIZE;

		Port.SwapGS();
		Port.WriteMSR(Syscall.Registers.IA32_GS_BASE, cast(ulong)syscallStack);
		Port.SwapGS();
	}

	void Sleep(List!Thread queue) {
		state = State.Sleeping;
		queue.Add(this);
		Task.Switch();
	}

	void WaitTime(DateTime time) {
		state = State.Waiting;
		waitFor.time = time;
	}

	void Start() {
		state = State.Running;
	}


//Syscalls
	override bool Accessible() { return true; }

	ulong SCall(ulong[] params) {
		if (params is null || !params.length)
			return ~0UL;

		switch (params[0]) {
			case IFace.Thread.S_CREATE:
				if (params.length < 2)
					return ~0UL;
				
				return (new Thread(cast(void function(ulong *))params[1])).ResID();
				break;

			default:
		}

		return ~0UL;
	}
}