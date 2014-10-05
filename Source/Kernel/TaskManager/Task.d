module TaskManager.Task;

import Core; //logs...
import Library;
import TaskManager;
import Architecture;
import ObjectManager;

extern(C) private void* _Proc_Read_RIP();


public struct SSEState {
	ulong Header;
	ulong Data;
}


public struct TaskState {
	void* RIP, RSP, RBP;
	SSEState SSE;
	bool IsSSEModified;
}


public abstract final class Task : IStaticModule {
	private __gshared ulong _nextPID = 1;
	private __gshared ulong _nextTID = 1;

	private __gshared SpinLock _spinLock;
	private __gshared LinkedList!Process _procs;
	private __gshared LinkedList!Thread[] _threads;
	private __gshared Thread _currentThread;

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

	@property public static Thread CurrentThread() {
		return _currentThread;
	}

	@property public static Process CurrentProcess() {
		return CurrentThread.ParentProcess;
	}

	@property package static ulong NextPID() {
		return _nextPID++;
	}

	@property package static ulong NextTID() {
		return _nextTID++;
	}

	public static bool Initialize() {
		_spinLock = new SpinLock();
		_procs    = new LinkedList!Process();
		_threads  = new LinkedList!Thread[Thread.MinPriority + 1];

		foreach (ref x; _threads)
			x = new LinkedList!Thread();

		Process proc = Process.Initialize();
		_currentThread = proc.Threads.First.Value;

		return true;
	}

	public static void Schelduler() {
		//Log.WriteLine("Trying to reschedule");

		if (_spinLock.IsLocked)
			return;
	
		if (CurrentThread._remaining--)
			return;

		/// Save RBP, RSP, RIP registers
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

	package static void Reschedule() {
		if (_spinLock.IsLocked)
			return;

		Thread next = GetNextToRun();
		if (CurrentThread == next)
			return;
		//if (!next)
		//	next = idle thread
		if (next is null)
			return;
			
		Log.WriteLine("Debug: rescheduled: ", next.ID);

		/// Save SSE. I think this is shit... WE already had saved SSE in RBP - 0xFFF & ~0x0F
		//TODO: need allocate some memory first....
		//Port.SaveSSE((cast(ulong)cur._savedState.SSE + 0x0F) & ~0x0F);
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

		if (CurrentThread.Status == ThreadStatus.Active) {}
			Threads[CurrentThread.Priority].Add(CurrentThread);

		Thread next = GetRunnable();
		if (next)
			next._remaining = next._quantum;

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

		return null;
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
}