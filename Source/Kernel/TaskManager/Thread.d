module TaskManager.Thread;

import Core;
import Library;
import TaskManager;
import Architecture;
import ObjectManager;
import SyscallManager;


public enum ThreadStatus {
	Null,
	Active,
	Sleeping,
	MutexSleep,
	RWLockSleep, //i dont know if ill implement RWLock
	SemaphoreSleep,
	QueueSleep,
	EventSleep,
	Waiting,
	PreInit,
	Zombie,
	Dead,
	Buried
}


public enum ThreadEvent : ulong {
	VFS       = 0x01,
	IPCMesage = 0x02,
	signal    = 0x04,
	Timer     = 0x08,
	ShortWait = 0x10,
	DeadChild = 0x20
}


public struct IPCMessage {
	Thread Source;
	byte[] Data;
}


public final class Thread {
	public enum StackSize       = 0x4000;
	public enum UserStackSize   = 0x1000; //0
	public enum MinPriority     = 10;
	public enum DefaultPriority = 5;
	public enum DefaultQuantum  = 5;
	private enum ThreadReturn   = 0xDEADC0DE;

	private ulong _id;
	private string _name;

	private ThreadStatus _status;
	private SpinLock _spinLock;

	private Process _process;
	private Thread _parent; //Parent thread under same process

	private LinkedList!Thread _lastDeadChild;
	private Mutex _deadChildLock;

	private ulong[] _kernelStack;
	private ulong[2] _syscallStack;
	private ulong[] _userStack;
	private TaskState _savedState;

	private int _curFailNum;
	private void* _faultHandler;

	private SignalType _pendingSignal;
	private LinkedList!(IPCMessage *) _messages;

	private int _quantum;
	private int _remaining;
	package int _curCPU; //TO DO: add after multiCPU support

	private ulong _eventState;
	private void* _waitPointer;
	private ulong _retStatus;

	private int _priority;

	//private int _errno; //WAT?

	// Create new thread for process
	package this(Process process) {
		_id            = Task.NextTID;
		_curCPU        = -1;
		_status        = ThreadStatus.PreInit;
		_process       = process;
		_name          = "Unnamed Thread";
		_remaining     = DefaultQuantum;
		_quantum       = DefaultQuantum;
		_priority      = DefaultPriority;

		_spinLock      = new SpinLock();
		_lastDeadChild = new LinkedList!Thread();
		_deadChildLock = new Mutex();
		_messages      = new LinkedList!(IPCMessage *)();
		_kernelStack   = new ulong[StackSize];
		_userStack     = new ulong[UserStackSize];//TODO: ParentProcess.AllocUserStack();

		_syscallStack[1] = cast(ulong)_kernelStack.ptr + StackSize / 2;

		_savedState.SSEInt.Header = cast(ulong)new byte[0x20F].ptr;
		_savedState.SSEInt.Data   = (_savedState.SSEInt.Header + 0x0F) & ~0x0F;

		_savedState.SSESyscall.Header = cast(ulong)new byte[0x20F].ptr;
		_savedState.SSESyscall.Data   = (_savedState.SSESyscall.Header + 0x0F) & ~0x0F;

		_process.Threads.Add(this);
	}

	// Clone thread from other under same process
	public this(Thread other) {
		this(other._process, other);
	}

	// Clone thread from other to the new process
	package this(Process process, Thread other) {
		this(process);
		_name         = other._name.dup;
		_remaining    = other._quantum;
		_quantum      = other._quantum;
		_priority     = other._priority;
		_faultHandler = other._faultHandler;

		if (process == other._process)
			_parent = other;

		Log.WriteLine("Clonned thread: ", _id);
	}

	~this() {
		RemoveActive();
		_status = ThreadStatus.Buried;
		_process.Threads.Remove(this);

		if (!_process.Threads.Count)
			delete _process;

		delete _name;
		delete _spinLock;
		delete _deadChildLock;
		delete _messages;
		delete _kernelStack;

		ulong* sse = cast(ulong *)_savedState.SSEInt.Header;
		delete sse;

		sse = cast(ulong *)_savedState.SSESyscall.Header;
		delete sse;
	}

	package void SetKernelStack() {
		CPU.TSSTable.RSP0 = _kernelStack.ptr + StackSize;

		Port.SwapGS();
		Port.WriteMSR(SyscallHandler.Registers.IA32_GS_BASE, cast(ulong)_syscallStack.ptr);
		Port.SwapGS();
	}

	@property public ulong ID() {
		return _id;
	}

	@property public void Name(string value) {
		delete _name;
		_name = value;
	}

	@property public string Name() {
		return _name;
	}

	@property public Process ParentProcess() {
		return _process;
	}

	@property public void* WaitPointer() {
		return _waitPointer;
	}

	@property public ref void* FaultHandler() {
		return _faultHandler;
	}

	@property public ref ThreadStatus Status() {
		return _status;
	}

	@property public ref ulong RetStatus() {
		return _retStatus;
	}

	@property public ref TaskState SavedState() {
		return _savedState;
	}

	@property public int Priority() {
		return _priority;
	}

	@property public ref int Quantum() {
		return _quantum;
	}

	@property public ref int Remaining() {
		return _remaining;
	}

	@property public void Priority(int priority) {
		if (priority < 0 || priority > MinPriority)
			priority = MinPriority;

		if (priority == _priority)
			return;

		if (this != Task.CurrentThread) {
			Task.ThreadLock.WaitOne();
			Task.Threads[_priority].Remove(this);
			Task.Threads[priority].Add(this);
			_priority = priority;
			Task.ThreadLock.Release();
		} else
			_priority = priority;
	}

	public void Start(void function() entryPoint, string[] args) { //TODO: args...
		//switch to new thread before run is called
		_savedState.RSP = cast(void *)_kernelStack.ptr + StackSize;
		_savedState.RIP = cast(void *)&NewThread;

		_kernelStack[0] = cast(ulong)entryPoint;
	}

	private static void NewThread() {
		with (Task.CurrentThread) {
			ParentProcess.PageTable.Install();
			//copy args to user stack

			Port.Cli();
			DeviceManager.EOI(0);

			if (Task.CurrentThread.ParentProcess.IsKernel)
				Run(0x202, _kernelStack[0], 0x08, 0x10);
			else
				Run(0x202, _kernelStack[0], 0x1B, 0x23);
		}
	}

	private void Run(ulong flags, ulong ip, ushort cs, ushort ss) {
		ulong* st = cast(ulong *)(cast(ulong)_userStack.ptr + UserStackSize);
		*st = ThreadReturn;

		*--st = ss;
		*--st = cast(ulong)_userStack.ptr + UserStackSize;
		*--st = flags;
		*--st = cs;
		*--st = ip;
	
		*--st = ss;
		*--st = ss;
		*--st = ss;
		*--st = ss;

		asm {
			"mov RSP, %0" : : "r"(st);

			"mov DS, [RSP]";
			"add RSP, 8";
			"mov ES, [RSP]";
			"add RSP, 8";
			"popq FS";
			"popq GS";

			"iretq";
		}
	}

	public ulong WaitTID(ulong tid, ref ThreadStatus status) {
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
				Log.WriteLine("Threads", "TODO: WaitTID(tid = -1) - Any Child");
		} else if (tid == 0)
			Log.WriteLine("Threads", "TODO: WaitTID(tid = 0) - Any Child/Sibling");
		else if (tid < -1)
			Log.WriteLine("Threads", "TODO: WaitTID(tid < -1) - TGID");
		else if (tid > 0) {
			ulong id;
			do
				id = WaitTID(-1, status);
			while (id != tid || id != -1);

			return id;
		}

		return -1;
	}

	public void Exit(ulong status) {
		Kill(status && 0xFF);

		while(true)
			Port.Halt();
	}

	public void Kill(ulong status) {
		bool isCurrentThread = this == Task.CurrentThread;

		_spinLock.WaitOne();
		scope(exit) _spinLock.Release();

		foreach (x; _messages) {
			auto a = x.Value;
			delete a;
		}

		Task.ThreadLock.WaitOne();
		switch (_status) {
			case ThreadStatus.PreInit:
				break;

			case ThreadStatus.Sleeping:
				break;

			case ThreadStatus.Active:
				if (!isCurrentThread)
					Task.Threads[_priority].Remove(this);

				_remaining = 0;
				_quantum = 0;
				break;

			case ThreadStatus.Zombie:
				Task.ThreadLock.Release();
				return;

			default:
				Log.WriteLine("Threads", "Kill - unsupported thread status");
		}

		_retStatus = status;
		_status = ThreadStatus.Zombie;
		Task.ThreadLock.Release();

		_parent._deadChildLock.WaitOne();
		_parent._lastDeadChild.Add(this);
		_parent.PostEvent(ThreadEvent.DeadChild);

		if (isCurrentThread)
			while (true)
				Yield();
	}

	public void Yield() {
		Task.Scheduler();
	}

	public void WaitForStatusEnd(ThreadStatus status) {
		assert(status != ThreadStatus.Active);
		assert(status != ThreadStatus.Dead);

		while (_status == status)
			Yield();
	}

	public ulong Sleep(ThreadStatus status, void* ptr, ulong num, SpinLock lock) {
		RemoveActive();
		_status = status;
		_waitPointer = ptr;
		_retStatus = num;

		if (lock)
			lock.Release();

		WaitForStatusEnd(status);
		_waitPointer = null;
		return _retStatus;
	}

	public void Sleep() {
		if (_messages.Count)
			return;

		RemoveActive();
		_status = ThreadStatus.Sleeping;
		WaitForStatusEnd(ThreadStatus.Sleeping);
	}

	public bool Wake() {
		switch (_status) {
			case ThreadStatus.Active:
				return false;

			case ThreadStatus.Sleeping:
				AddActive();
				return true;

			case ThreadStatus.SemaphoreSleep:
				Semaphore semaphore = cast(Semaphore)_waitPointer;
				semaphore.LockInternal();
				scope(exit) semaphore.UnlockInternal();

				if (!semaphore.Waiting.Remove(this) && !semaphore.Signaling.Remove(this))
					return false;
					
				_retStatus = 0;
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

	public void RemoveActive() {
		Task.ThreadLock.WaitOne();
		Task.Threads[_priority].Remove(this);
		Task.ThreadLock.Release();
	}

	public void AddActive() {
		if (_status == ThreadStatus.Active || !_savedState.RIP)
			return;
		_status = ThreadStatus.Active;

		Task.ThreadLock.WaitOne();
		if (Task.CurrentThread != this)
			Task.Threads[_priority].Add(this);
		Task.ThreadLock.Release();
	}

	public void Fault(int number) {
		if (_faultHandler is null) { // Panic
			Kill(-1);
			Port.Sti();
			Port.Halt();
		}

		if (_curFailNum) { // Double fail
			Kill(-1);
			Log.WriteLine("Threads", "Fault: Double fault...");

			Port.Sti();
			Port.Halt();
		}

		_curFailNum = number;
		//TODO: Task.CallFaultHandler(this) ???
	}

	public void SegFault(void* address) {
		Log.WriteLine("Threads", "Fault: segment fault...");
		Fault(1);
	}




	//Signals
	public void PostSignal(SignalType signal) {
		_pendingSignal = signal;
		PostEvent(ThreadEvent.signal);
	}
	//TODO




	//Events
	public void PostEvent(ulong eventMask) {
		_spinLock.WaitOne();
		scope(exit) _spinLock.Release();

		_eventState |= eventMask;

		switch (_status) {
			case ThreadStatus.EventSleep:
				if (_retStatus & eventMask)
					AddActive();
				break;

			case ThreadStatus.SemaphoreSleep:
				if (eventMask & ThreadEvent.Timer)
						Semaphore.ForceWake(this);
				break;

			default:
		}
	}

	public void ClearEvent(ulong eventMask) {
		_eventState &= ~eventMask;
	}

	public ulong WaitEvents(ulong eventMask) {
		if (!eventMask)
			return 0;

		_spinLock.WaitOne();
		scope(exit) _spinLock.Release();

		if ((_eventState & eventMask) == 0) {
			Sleep(ThreadStatus.EventSleep, null, eventMask, _spinLock);
			_spinLock.WaitOne();
		}

		ulong ret = _eventState & eventMask;
		_eventState &= ~eventMask;

		return ret;
	}


	//Messages
	public bool SendMessage(byte[] data) {
		_spinLock.WaitOne();
		scope(exit) _spinLock.Release();

		if (_status == ThreadStatus.Dead)
			return false;

		IPCMessage* msg = new IPCMessage();
		msg.Source = Task.CurrentThread;
		msg.Data[] = data;
		_messages.Add(msg);

		PostEvent(ThreadEvent.IPCMesage);
		return true;
	}

	public bool GetMessage(ref Thread source, ref byte[] data) {
		if (!_messages.Count)
			return false;

		_spinLock.WaitOne();
		scope(exit) _spinLock.Release();

		source = _messages.First.Value.Source;
		data = _messages.First.Value.Data;
		_messages.RemoveFirst();

		if (_messages.Count)
			_eventState |= ThreadEvent.IPCMesage;

		return true;
	}
}