module TaskManager.Task;

import TaskManager.Process;
import TaskManager.Thread;
import System.Collections.Generic.All;
import Architectures.Port;

extern(C) ulong read_rip();


class Task {
static:
package:
	List!(Process) Procs;
	List!(Thread) Threads;
	Thread currentThread;
	Thread idleThread;

public:
	@property Thread CurrentThread() { return currentThread; }
	@property Process CurrentProcess() { return currentThread.parent; }


	this() {
		Procs = new List!(Process)();
		//Threads = new List!(Thread)();

		Process.Init();
		currentThread = Threads[0];
		//todo idle thread
	}

	Thread NextThread() {
		if (currentThread is null)
			currentThread = Threads[0];

		foreach (x; Threads[Threads.IndexOf(currentThread) .. $]) {
			if (x.Runnable() && x != idleThread)
				return x;
		}

		foreach (x; Threads[0 .. Threads.IndexOf(currentThread)]) {
			if (x.Runnable() && x != idleThread)
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
	}
}