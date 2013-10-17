module TaskManager.Task;

import TaskManager.Process;
import TaskManager.Thread;
import TaskManager.Signal;
import Architectures.Port;
import System.DateTime;
import System.Collections.Generic.List;
import Core.Log;


extern(C) ulong read_rip();
extern(C) void idle_task();


class Task {
static:
private:
	__gshared ulong pid = 1, tid = 1;


package:
	__gshared List!Process Procs;
	__gshared List!Thread Threads;
	__gshared Thread currentThread;
	__gshared Thread idleThread;


public:
	@property ulong NewPID() { return pid++; }
	@property ulong NewTID() { return tid++; }
	@property Thread CurrentThread() { return currentThread; }
	@property Process CurrentProcess() { return currentThread.parent; }
	@property List!Thread GetAllThreads() { return Threads; }
	@property List!Process GetAllProcesses() { return Procs; }


	bool Init() {
		Procs = new List!Process();
		Threads = new List!Thread();

		Process.Init();
		currentThread = Threads[0];
		Log.Result(true);

		Log.Print(" - Initializing idle task");
		idleThread = new Thread(cast(void function())&idle_task);
		idleThread.rip = cast(ulong)&idle_task;
		Log.Result(true);

		Log.Print(" - Initializing signal handler");
		Signal.Init();
		return true;
	}

	private Thread NextThread(Thread.State state) {
		if (currentThread is null)
			currentThread = Threads[0];

		long idx = Threads.IndexOf(currentThread) + 1;
		
		//import Core.Log;
		//import System.Convert;
		//Log.Print("aaa: " ~ Convert.ToString(idx));
		//Log.Print("bbb: " ~ Convert.ToString(Threads.Count));


		if (idx + 1 < Threads.Count) {
			foreach (x; Threads[idx .. $]) {
				if (x.Valid(state) && x !is idleThread)
					return x;
			}
		}

		foreach (x; Threads[0 .. idx]) {
			if (x.Valid(state) && x !is idleThread)
				return x;
		}

		return idleThread;
	}

	void Reap(Thread thread) {
		
	}

	void Switch() {
		ulong rsp, rbp, rip;
		asm {
			mov rsp, RSP;
			mov rbp, RBP;
		}

		rip = read_rip();
		if (rip == 0xFEEDCAFEUL) {
			foreach (x; Threads) {
				if (x !is null && x.Valid(Thread.State.Zombie))
					Reap(x);
			}

			if (CurrentThread == CurrentProcess.threads[0]) {
				if (CurrentProcess.signalQueue.Count) {
					SigNum signal = CurrentProcess.signalQueue[0];
					CurrentProcess.signalQueue.RemoveAt(0);
					Signal.Handler(CurrentProcess, signal);
				}
			}

			return;
		}

		CurrentThread.rsp = rsp;
		CurrentThread.rbp = rbp;
		CurrentThread.rip = rip;


		//Run new thread
		currentThread = NextThread(Thread.State.Running);

		if (CurrentThread == CurrentProcess.threads[0])
			Signal.FixStack();

		rsp = CurrentThread.rsp;
		rbp = CurrentThread.rbp;
		rip = CurrentThread.rip;


		Port.Cli();
		CurrentThread.SetKernelStack();
		CurrentProcess.paging.Install();

		if (CurrentThread == CurrentProcess.threads[0] && CurrentProcess.signalStack is null) {
			if (CurrentProcess.signalQueue.Count) {
				CurrentProcess.signalStack = (new ulong[Thread.STACK_SIZE]).ptr;
				CurrentProcess.signalState.rip = CurrentThread.rip;
				CurrentProcess.signalState.rsp = CurrentThread.rsp;
				CurrentProcess.signalState.rbp = CurrentThread.rbp;
			}
		}

		asm {
			mov RAX, rbp;
			mov RBX, rsp;
			mov RCX, rip;

			mov RBP, RAX;
			mov RSP, RBX;
			mov RAX, 0xFEEDCAFEUL;
			jmp RCX;
		}
	}

	/*
		queue is extern list of sleeping threads.
		for ex. if 3 threads are w8ing for input so they call sleep for theyselfs and
		w8 for any1 call write func who call wakeup func who wakes up all sleeping threads
	*/
	void Wakeup(List!Thread queue) {
	//	foreach (x; queue)
	//		x.state = Thread.State.Running;
	}

	void WakeupSleepers(DateTime time) {
	//	foreach (x; Threads) {
	//		if (x !is null && x.Valid(Thread.State.Waiting) && x.waitFor.time >= time)
	//			x.state = Thread.State.Running;
	//	}
	}

	void Exit(long retval) {
		CurrentThread.retval = retval;
		CurrentThread.state = Thread.State.Zombie;
		Switch();
	}
}