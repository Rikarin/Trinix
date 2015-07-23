/**
 * Copyright (c) 2014-2015 Trinix Foundation. All rights reserved.
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
 * http://bit.ly/1wIYh3A and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module TaskManager.Thread;

import Core;
import Library;
import TaskManager;
import Architecture;
import ObjectManager;
import SyscallManager;
import MemoryManager;


enum ThreadStatus {
	Null,
	Active,
	Sleeping,
	MutexSleep,
	RWLockSleep,
	SemaphoreSleep,
	QueueSleep,
	EventSleep,
	Waiting,
	PreInit,
	Zombie,
	Dead,
	Buried
}

enum ThreadEvent : ulong {
	VFS       = 0x01,
	IPCMesage = 0x02,
	signal    = 0x04,
	Timer     = 0x08,
	ShortWait = 0x10,
	DeadChild = 0x20
}

struct IPCMessage {
	Thread Source;
	byte[] Data;
}

final class Thread {
	enum STACK_SIZE       = 0x4000;
	enum USER_STACK_SIZE   = 0x1000; //* 10
	enum MIN_PRIORITY     = 10;
	enum DEFAULT_PRIORITY = 5;
	enum DEFAULT_QUANTUM  = 5;
	private enum THREAD_RETURN   = 0xDEADC0DE; //TODO: deprecated

	private ulong m_id;
	private string m_name;

	private ThreadStatus m_status;
	private SpinLock m_spinLock;

	private Process m_process;
	private Thread m_parent; /* Parent thread in same process */

	private LinkedList!Thread m_lastDeadChild;
	private Mutex m_deadChildLock;

	private ulong[] m_kernelStack;
	private ulong[2] m_syscallStack;
	private ulong[] m_userStack;
	private TaskState m_savedState;

	private long m_curFaultNum;
	private void* m_faultHandler; //WTF?

	private SignalType m_pendingSignal;
	private LinkedList!(IPCMessage *) m_messages;

	private int m_quantum;
	private int m_remaining;
	//package int _curCPU;

	private ulong m_eventState;
	private void* m_waitPointer; //WTF??
	private ulong m_retStatus;

	private int m_priority;

	//private int _errno; //WAT?

	/* Create new thread for process */
	package this(Process process) {
		m_id            = Task.NextTID;
		//_curCPU        = -1;
		m_status        = ThreadStatus.PreInit;
		m_process       = process;
		m_name          = "Unnamed Thread";
		m_remaining     = DEFAULT_QUANTUM;
		m_quantum       = DEFAULT_QUANTUM;
		m_priority      = DEFAULT_PRIORITY;

		m_spinLock      = new SpinLock();
		m_lastDeadChild = new LinkedList!Thread();
		m_deadChildLock = new Mutex();
		m_messages      = new LinkedList!(IPCMessage *)();
		m_kernelStack   = new ulong[STACK_SIZE];
		m_userStack     = new ulong[USER_STACK_SIZE];//TODO: ParentProcess.AllocUserStack();

		m_syscallStack[1] = cast(ulong)m_kernelStack.ptr + STACK_SIZE / 2;

		m_savedState.SSEInt.Header = cast(ulong)new byte[0x20F].ptr;
		m_savedState.SSEInt.Data   = (m_savedState.SSEInt.Header + 0x0F) & ~0x0F;

		m_savedState.SSESyscall.Header = cast(ulong)new byte[0x20F].ptr;
		m_savedState.SSESyscall.Data   = (m_savedState.SSESyscall.Header + 0x0F) & ~0x0F;

		m_process.Threads.Add(this);
	}

	/* Clone thread from other under same process */
	this(Thread other) {
		this(other.m_process, other);
	}

	/* Clone thread from other to the new process */
	package this(Process process, Thread other) {
		this(process);
		m_name         = other.m_name.dup;
		m_remaining    = other.m_quantum;
		m_quantum      = other.m_quantum;
		m_priority     = other.m_priority;
		m_faultHandler = other.m_faultHandler;

		if (process == other.m_process)
			m_parent = other;

		Log("Clonned thread %d", m_id);
	}

	~this() {
		RemoveActive();
		m_status = ThreadStatus.Buried;
		m_process.Threads.Remove(this);

		if (!m_process.Threads.Count)
			delete m_process;

		delete m_name;
		delete m_spinLock;
		delete m_deadChildLock;
		delete m_messages;
		delete m_kernelStack;

		ulong* sse = cast(ulong *)m_savedState.SSEInt.Header;
		delete sse;

		sse = cast(ulong *)m_savedState.SSESyscall.Header;
		delete sse;
	}

	package void SetKernelStack() {
		CPU.TSSTable.RSP0 = cast(v_addr)m_kernelStack.ptr + STACK_SIZE;

		Port.SwapGS();
		Port.WriteMSR(SyscallHandler.Registers.IA32_GS_BASE, cast(ulong)m_syscallStack.ptr);
		Port.SwapGS();
	}

    @property {
        ulong ID()                 { return m_id; }
        string Name()              { return m_name; }
        int Priority()             { return m_priority; }
        ref int Quantum()          { return m_quantum; }
        void* WaitPointer()        { return m_waitPointer; }
        ref int Remaining()        { return m_remaining; }
        ref ulong RetStatus()      { return m_retStatus; }
        long CurrentFaultNum()     { return m_curFaultNum; }
        Process ParentProcess()    { return m_process; }
        ref void* FaultHandler()   { return m_faultHandler; }
        ref ThreadStatus Status()  { return m_status; }
        ref TaskState SavedState() { return m_savedState; }
        
        void Name(string value) {
            delete m_name;
            m_name = value;
        }
        
        void Priority(int priority) {
            if (priority < 0 || priority > MIN_PRIORITY)
                priority = MIN_PRIORITY;
            
            if (priority == m_priority)
                return;
            
            if (this != Task.CurrentThread) {
                Task.ThreadLock.WaitOne();
                Task.Threads[m_priority].Remove(this);
                Task.Threads[priority].Add(this);
                m_priority = priority;
                Task.ThreadLock.Release();
        } else
            m_priority = priority;
        }
    }

	void Start(void function() entryPoint, string[] args) { //TODO: args...
		m_savedState.RSP = cast(void *)m_kernelStack.ptr + STACK_SIZE;
		m_savedState.RIP = cast(void *)&NewThread;

		m_kernelStack[0] = cast(ulong)entryPoint;
	}

	private static void NewThread() {
		with (Task.CurrentThread) {
			ParentProcess.PageTable.Install();
			//copy args to user stack

			Port.Cli();
			DeviceManager.EOI(0);

			if (Task.CurrentThread.ParentProcess.IsKernel)
				Run(0x202, m_kernelStack[0], 0x08, 0x10);
			else
				Run(0x202, m_kernelStack[0], 0x1B, 0x23);
		}
	}

	private void Run(ulong flags, ulong ip, ushort cs, ushort ss) {
		ulong* st = cast(ulong *)(cast(ulong)m_userStack.ptr + USER_STACK_SIZE);
		*st = THREAD_RETURN;

		*--st = ss;
		*--st = cast(ulong)m_userStack.ptr + USER_STACK_SIZE;
		*--st = flags;
		*--st = cs;
		*--st = ip;
	
		*--st = ss;
		*--st = ss;
		*--st = ss;
		*--st = ss;

		asm {
			mov RSP, st;
			mov DS, [RSP];
			add RSP, 8;
			mov ES, [RSP];
			add RSP, 8;
			popq FS;
			popq GS;

			iretq;
		}
	}

/*	ulong WaitTID(ulong tid, ref ThreadStatus status) {
		if (tid == -1) {
			ulong events = WaitEvents(ThreadEvent.DeadChild);
			if (events & ThreadEvent.DeadChild) {
				assert(_lastDeadChild.Count);
				Thread deadThread = _lastDeadChild.First.Value;
				_lastDeadChild.RemoveFirst();

				if (_lastDeadChild.Count)
					PostEvent(ThreadEvent.DeadChild);
				else
					ClearEvent(ThreadEvent.DeadChild);
				_deadChildLock.Release();

				assert(deadThread._status == ThreadStatus.Zombie);
				deadThread._status = ThreadStatus.Dead;

				ulong ret = deadThread._id;
				status = deadThread._status;
				delete deadThread;
				return ret;
			} else
				Log("Threads: TODO: WaitTID(tid = -1) - Any Child");
		} else if (tid == 0)
			Log("Threads: TODO: WaitTID(tid = 0) - Any Child/Sibling");
		else if (tid < -1)
			Log("Threads: TODO: WaitTID(tid < -1) - TGID");
		else if (tid > 0) {
			ulong id;
			do
				id = WaitTID(-1, status);
			while (id != tid || id != -1);

			return id;
		}

		return -1;
	}
*/
	void Exit(ulong status) {
		Kill(status && 0xFF);

		while(true)
			Port.Halt();
	}

	void Kill(ulong status) {
		bool isCurrentThread = this == Task.CurrentThread;

		m_spinLock.WaitOne();
		scope(exit) m_spinLock.Release();

		foreach (x; m_messages) {
			auto a = x.Value;
			delete a;
		}

		Task.ThreadLock.WaitOne();
		switch (m_status) {
			case ThreadStatus.PreInit:
				break;

			case ThreadStatus.Sleeping:
				break;

			case ThreadStatus.Active:
				if (!isCurrentThread)
					Task.Threads[m_priority].Remove(this);

				m_remaining = 0;
				m_quantum = 0;
				break;

			case ThreadStatus.Zombie:
				Task.ThreadLock.Release();
				return;

			default:
				Log("Threads: Kill - unsupported thread status");
		}

		m_retStatus = status;
		m_status = ThreadStatus.Zombie;
		Task.ThreadLock.Release();

		m_parent.m_deadChildLock.WaitOne();
		m_parent.m_lastDeadChild.Add(this);
		m_parent.PostEvent(ThreadEvent.DeadChild);

		if (isCurrentThread)
			while (true)
				Yield();
	}

	void Yield() {
		Task.Scheduler();
	}

	void WaitForStatusEnd(ThreadStatus status) {
		assert(status != ThreadStatus.Active);
		assert(status != ThreadStatus.Dead);

		while (m_status == status)
			Yield();
	}

	ulong Sleep(ThreadStatus status, void* ptr, ulong num, SpinLock lock) {
		RemoveActive();
		m_status = status;
		m_waitPointer = ptr;
		m_retStatus = num;

		if (lock)
			lock.Release();

		WaitForStatusEnd(status);
		m_waitPointer = null;
		return m_retStatus;
	}

	void Sleep() {
		if (m_messages.Count)
			return;

		RemoveActive();
		m_status = ThreadStatus.Sleeping;
		WaitForStatusEnd(ThreadStatus.Sleeping);
	}

	bool Wake() {
		switch (m_status) {
			case ThreadStatus.Active:
				return false;

			case ThreadStatus.Sleeping:
				AddActive();
				return true;

			case ThreadStatus.SemaphoreSleep:
				Semaphore semaphore = cast(Semaphore)m_waitPointer;
				semaphore.LockInternal();
				scope(exit) semaphore.UnlockInternal();

				if (!semaphore.Waiting.Remove(this) && !semaphore.Signaling.Remove(this))
					return false;
					
				m_retStatus = 0;
				AddActive();
				return true;

			case ThreadStatus.Waiting:
				return false;

			case ThreadStatus.Dead:
				return false;

			default:
				return false;
		}
	}

	void RemoveActive() {
		Task.ThreadLock.WaitOne();
		Task.Threads[m_priority].Remove(this);
		Task.ThreadLock.Release();
	}

	void AddActive() {
		if (m_status == ThreadStatus.Active || !m_savedState.RIP)
			return;
		m_status = ThreadStatus.Active;

		Task.ThreadLock.WaitOne();
		if (Task.CurrentThread != this)
			Task.Threads[m_priority].Add(this);
		Task.ThreadLock.Release();
	}

	void Fault(long number) {
		if (m_faultHandler is null) {    /* Panic */
			Kill(-1);

			Port.Sti();
			Port.Halt();
			return;
		}

		if (m_curFaultNum) {             /* Double fault */
			Log("Threads: Fault: Double fault...");
			Kill(-1);

			Port.Sti();
			Port.Halt();
			return;
		}

		m_curFaultNum = number;
		Task.CallFaultHandler(this);
	}

	void SegFault(void* address) {
		Log("Threads: Fault: segment fault...");
		Fault(1);
	}




	/* Signals */
	void PostSignal(SignalType signal) {
		m_pendingSignal = signal;
		PostEvent(ThreadEvent.signal);
	}
	//TODO




	/* Events */
	void PostEvent(ulong eventMask) {
		m_spinLock.WaitOne();
		scope(exit) m_spinLock.Release();

		m_eventState |= eventMask;

		switch (m_status) {
			case ThreadStatus.EventSleep:
				if (m_retStatus & eventMask)
					AddActive();
				break;

			case ThreadStatus.SemaphoreSleep:
				if (eventMask & ThreadEvent.Timer)
						Semaphore.ForceWake(this);
				break;

			default:
		}
	}

	void ClearEvent(ulong eventMask) {
		m_eventState &= ~eventMask;
	}

	ulong WaitEvents(ulong eventMask) {
		if (!eventMask)
			return 0;

		m_spinLock.WaitOne();
		scope(exit) m_spinLock.Release();

		if ((m_eventState & eventMask) == 0) {
			Sleep(ThreadStatus.EventSleep, null, eventMask, m_spinLock);
			m_spinLock.WaitOne();
		}

		ulong ret = m_eventState & eventMask;
		m_eventState &= ~eventMask;

		return ret;
	}

	/* Messages */
	bool SendMessage(byte[] data) {
		m_spinLock.WaitOne();
		scope(exit) m_spinLock.Release();

		if (m_status == ThreadStatus.Dead)
			return false;

		IPCMessage* msg = new IPCMessage();
		msg.Source = Task.CurrentThread;
		msg.Data[] = data;
		m_messages.Add(msg);

		PostEvent(ThreadEvent.IPCMesage);
		return true;
	}

	bool GetMessage(ref Thread source, ref byte[] data) {
		if (!m_messages.Count)
			return false;

		m_spinLock.WaitOne();
		scope(exit) m_spinLock.Release();

		source = m_messages.First.Value.Source;
		data = m_messages.First.Value.Data;
		m_messages.RemoveFirst();

		if (m_messages.Count)
			m_eventState |= ThreadEvent.IPCMesage;

		return true;
	}
}