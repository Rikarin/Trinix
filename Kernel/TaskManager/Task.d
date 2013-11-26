module TaskManager.Task;

import Core;
import TaskManager;
import Architectures;

import System;
import System.Collections.Generic;


extern(C) ulong read_rip();
extern(C) void idle_task();


class Task {
static:
private:
	__gshared ulong pid = 1, tid = 1;
	__gshared Thread currentThread;
	__gshared Thread idleThread;
	__gshared long scheldule = 1;

package:
	__gshared List!Process Procs;
	__gshared List!Thread Threads;


public:
	@property ulong NewPID() { return pid++; }
	@property ulong NewTID() { return tid++; }
	@property Thread CurrentThread() { return currentThread; }
	@property Process CurrentProcess() { return currentThread.parent; }
	@property List!Thread GetAllThreads() { return Threads; }
	@property List!Process GetAllProcesses() { return Procs; }


	bool Init() {
	//	Procs = new List!Process(0x200); //FIX ME ;((((
	//	Threads = new List!Thread(0x200); //ME TOO PLZZZZ

		Process.Init();
		currentThread = Threads[0];
		Log.Result(true);

		Log.Print(" - Initializing idle task");
		idleThread = new Thread(cast(void function(ulong*))&idle_task);
		idleThread.rip = cast(ulong)&idle_task;
		idleThread.state = Thread.State.Running;
		Log.Result(true);

		Log.Print(" - Initializing signal handler");
		Signal.Init();
		return true;
	}

	private Thread NextThread() {
   		/*import Core.Log;
        import System.Convert;
        Log.PrintSP(" " ~ Convert.ToString(scheldule));
        Log.PrintSP(" <=> " ~ Convert.ToString(Threads.Count));
*/

		long lst = scheldule++;
		if (scheldule < Threads.Count) {
			foreach (x; Threads[scheldule .. $])
				if (x.Valid(Thread.State.Running) && x !is idleThread)
					return x;
		}

		for (scheldule = 0; scheldule <= lst; scheldule++)
			if (Threads[scheldule].Valid(Thread.State.Running) && Threads[scheldule] !is idleThread)
				return Threads[scheldule];

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
			/*foreach (x; Threads) {
				if (x !is null && x.Valid(Thread.State.Zombie))
					Reap(x);
			}*/

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
		currentThread = NextThread();

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
				CurrentProcess.signalStack = (new ulong[Thread.STACK_SIZE]).ptr + Thread.STACK_SIZE;
				*CurrentProcess.signalStack = Signal.SignalReturn;

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
		foreach (x; queue)
			x.state = Thread.State.Running;

		queue.Clear();
	}

	void WakeupSleepers(DateTime time) {
	//	foreach (x; Threads) {
	//		if (x !is null && x.Valid(Thread.State.Waiting) && x.waitFor.time >= time)
	//			x.state = Thread.State.Running;
	//	}
	}

	void Exit(long retval) {
		if (CurrentThread == CurrentProcess.threads[0])
			CurrentProcess.retval = retval;
		CurrentThread.state = Thread.State.Zombie;
		Switch();
	}
}