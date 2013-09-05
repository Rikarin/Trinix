module TaskManager.Task;

import TaskManager.Process;
import TaskManager.Thread;
import System.Collections.Generic.All;
import Architectures.Port;

extern(C) ulong read_rip();


class Task {
static:
private:
	ulong pid;

package:
	List!(Process) Procs;
	List!(Thread) Threads;
	Thread currentThread;
	Thread idleThread;

public:
	@property ulong NewPID() { return pid++; }
	@property Thread CurrentThread() { return currentThread; }
	@property Process CurrentProcess() { return currentThread.parent; }


	this() {
		Procs = new List!(Process)();
		//Threads = new List!(Thread)();

		Process.Init();
		currentThread = Threads[0];
		//todo idle thread
	}

	Thread NextThread(Thread.State state) {
		if (currentThread is null)
			currentThread = Threads[0];

		long idx = Threads.IndexOf(currentThread);
		foreach (x; Threads[idx .. $]) {
			if (x.Valid(state) && x != idleThread)
				return x;
		}

		foreach (x; Threads[0 .. idx]) {
			if (x.Valid(state) && x != idleThread)
				return x;
		}

		return idleThread;
	}

	void Switch() {
		ulong rsp, rbp, rip;
		asm {
			mov rsp, RSP;
			mov rbp, RBP;
		}

		rip = read_rip();
		if (rip == 0xFEEDCAFE) {
			//signals etc...
			return;
		}

		CurrentThread.rsp = rsp;
		CurrentThread.rbp = rbp;
		CurrentThread.rip = rip;


		//Run new thread
		currentThread = NextThread(Thread.State.Running);
		rsp = CurrentThread.rsp;
		rbp = CurrentThread.rbp;
		rip = CurrentThread.rip;

		CurrentThread.SetKernelStack();
		//CurrentProcess.paging.Install();

		//dake picoviny zo signalmi

		asm {
			mov RBP, rbp;
			mov RSP, rsp;
			mov RCX, rip;
			mov RAX, 0xFEEDCAFE;
			jmp RCX;
		}
	}
}