module TaskManager.Process;

import Library;
import VFSManager;
import TaskManager;
import Architecture;
import MemoryManager;
import SyscallManager;


public final class Process {
	private void* _userStack = cast(void *)0xFFFFFFFF80000000;

	private ulong _id;
	private ulong _uid;
	private ulong _gid;
	private bool _isKernel;

	private Process _parent;
	package Paging _paging;
	private LinkedList!Thread _threads;
	private DirectoryNode _cwd;
	private LinkedList!FSNode _descriptors;

	/// Use this against _descriptors for holding every used resource for thread eg. mutex, semaphore, fsnode, etc.
	/// And when process crash/exit we can easily delete objects created by this process.
	private LinkedList!Resource _resources;


	//TODO: Signal handlers?

	@property package LinkedList!Thread Threads() {
		return _threads;
	}

	@property public ulong ID() {
		return _id;
	}

	@property public Paging PageTable() {
		return _paging;
	}

	@property public bool IsKernel() {
		return _isKernel;
	}


	package static Process Initialize() {
		if (Task.ThreadCount)
			return null;

		Process process   = new Process();
		process._paging   = VirtualMemory.KernelPaging;
		process._cwd      = VFS.Root;
		process._isKernel = true;

		Thread t          = new Thread(process);
		t.Name            = "Init";
		t.Status          = ThreadStatus.Active;
		t.SetKernelStack();

		//Idle task
		Task.IdleTask     = new Thread(t);
		with (Task.IdleTask) {
			Name          = "Idle Task";
			Priority      = MinPriority;
			Quantum       = 1;
			Start(&Task.Idle, null);
		}
	
		return process;
	}

	private this() {
		_id          = Task.NextPID;
		_threads     = new LinkedList!Thread();
		_descriptors = new LinkedList!FSNode();

		Task.Processes.Add(this);
	}

	// Clone other._process to this process and thread other to this process
	public this(Thread other) {
		this();
		_uid         = other.ParentProcess._uid;
		_gid         = other.ParentProcess._gid;
		_isKernel    = other.ParentProcess._isKernel;
		_parent      = other.ParentProcess;
		_paging      = new Paging(other.ParentProcess._paging);
		_cwd         = other.ParentProcess._cwd;
		_descriptors = other.ParentProcess._descriptors; //TODO: deprecated + clone every resource...

		new Thread(this, other);
	}

	~this() {
		foreach (x; _resources) {
			if (x.Value.DetachProcess(this))
				delete x.Value;
		}

		foreach (x; _threads)
			delete x;

		delete _paging;
		delete _threads;
		delete _resources;
		delete _descriptors;

		// Clean up?
	}

	package ulong[] AllocUserStack(ulong size = Thread.UserStackSize) {
		for (ulong i = 0; i < size; i += Paging.PageSize) {
			_userStack -= Paging.PageSize;
			_paging.AllocFrame(_userStack, AccessMode.DefaultUser); //Nejako nefunguje :/
		}

		return (cast(ulong *)_userStack)[0 .. size];
	}
}