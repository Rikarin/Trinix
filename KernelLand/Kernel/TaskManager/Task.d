/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module TaskManager.Task;

import Core; //TODO: logs...
import Library;
import TaskManager;
import Architecture;
import ObjectManager;

extern(C) private void* _Proc_Read_RIP();


struct SSEState {
	ulong Header;
	ulong Data;
}


struct TaskState {
	void* RIP, RSP, RBP;
	SSEState SSEInt;
	SSEState SSESyscall;
	bool IsSSEModified;
}


abstract final class Task {
	private __gshared ulong _nextPID = 1;
	private __gshared ulong _nextTID = 1;

	private __gshared SpinLock _spinLock;
	private __gshared LinkedList!Process _procs;
	private __gshared LinkedList!Thread[] _threads;
	private __gshared Thread _currentThread;
	private __gshared Thread _idle;

	@property package static SpinLock ThreadLock() {
		return _spinLock;
	}

	@property package static LinkedList!Thread[] Threads() {
		return _threads;
	}

	@property package static LinkedList!Process Processes() {
		return _procs;
	}

	@property package static size_t ThreadCount() {
		size_t count;
		foreach (x; _threads)
			if (x !is null)
				count += x.Count;

		return count;
	}

	@property static Thread CurrentThread() {
		return _currentThread;
	}

	@property static Process CurrentProcess() {
		return CurrentThread.ParentProcess;
	}

	@property package static ulong NextPID() {
		return _nextPID++;
	}

	@property package static ulong NextTID() {
		return _nextTID++;
	}

	@property package static ref Thread IdleTask() {
		return _idle;
	}

	static void Initialize() {
		_spinLock = new SpinLock();
		_procs    = new LinkedList!Process();
		_threads  = new LinkedList!Thread[Thread.MinPriority + 1];

		foreach (ref x; _threads)
			x = new LinkedList!Thread();

		Process proc = Process.Initialize();
		_currentThread = proc.Threads.First.Value;
	}

	static void Scheduler() {
		if (_spinLock.IsLocked)
			return;
	
		if (CurrentThread.Remaining--)
			return;

		void* rsp, rbp;
		asm {
			"mov %0, RSP" : "=r"(rsp);
			"mov %0, RBP" : "=r"(rbp);
		}

		void* rip = _Proc_Read_RIP();
		if (cast(ulong)rip == 0x12341234UL)
			return;

		CurrentThread.SavedState.RIP = rip;
		CurrentThread.SavedState.RSP = rsp;
		CurrentThread.SavedState.RBP = rbp;

		Reschedule();
	}

	private static void Reschedule() {
		Thread next = GetNextToRun();
		//Log.WriteLine("Debug: rescheduled: ", next.ID, " priority: ", next.Priority, " name: ", next.Name);

		if (next is null || next == CurrentThread)
			return;
			
		//CurrentThread.SavedState.IsSSEModified = false;
		//Port.DisableSSE();

		/// Change to next thread
		_currentThread = next;
		_currentThread.SetKernelStack();
		_currentThread.ParentProcess._paging.Install();

		with (CurrentThread.SavedState)
			SwitchTasks(RSP, RBP, RIP);
	}

	private static Thread GetNextToRun() {
		ThreadLock.WaitOne();
		scope(exit) ThreadLock.Release();

		if (CurrentThread.Status == ThreadStatus.Active)
			Threads[CurrentThread.Priority].Add(CurrentThread);

		Thread next = GetRunnable();
		next.Remaining = next.Quantum;
		return next;
	}

	private static Thread GetRunnable() {
		foreach (x; _threads) {
			if (x.Count) {
				foreach (y; x) {
					if (y.Value.Status == ThreadStatus.Active) {
						Thread ret = y.Value;
						x.Remove(y);
						return ret;
					}
				}
			}
		}

		return _idle;
	}

	private static void SwitchTasks(void* rsp, void* rbp, void* rip) {		
		asm {
			"pop RBP"; //Naked
			"movq RBP, RSI";
			"movq RSP, RDI";
			"movq RAX, 0x12341234";
			"jmp RDX";
		}
	}

	package static void CallFaultHandler(Thread thread) {
		Log("Threads: Fault %d", thread.CurrentFaultNum);
		thread.Kill(-1);
		
		Port.Sti();
		Port.Halt();
		return;
	}

	package static void Idle() { //This is idle task
		while (true)
			Port.Halt();
	}
}