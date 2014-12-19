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
 * 
 * TODO:
 *      o Signal handler
 */

module TaskManager.Process;

import Library;
import VFSManager;
import TaskManager;
import Architecture;
import MemoryManager;
import SyscallManager;


final class Process {
	private void* _userStack = cast(void *)0xFFFFFFFF80000000;

	private ulong _id;
	private ulong _uid;
	private ulong _gid;
	private bool _isKernel;

	private Process _parent;
	package Paging _paging;
	private LinkedList!Thread _threads;
	private DirectoryNode _cwd;

	private List!Resource _resources;

	@property package LinkedList!Thread Threads() {
		return _threads;
	}

	@property ulong ID() {
		return _id;
	}

	@property ulong UID() {
		return _uid;
	}

	@property ulong GID() {
		return _gid;
	}

	@property Paging PageTable() {
		return _paging;
	}

	@property bool IsKernel() {
		return _isKernel;
	}


	package static Process Initialize() {
		if (Task.ThreadCount)
			return null;

		Process process   = new Process();
		process._paging   = VirtualMemory.KernelPaging;
		process._cwd      = VFS.Root;
		process._isKernel = true;

        /* Kernel thread */
		Thread t          = new Thread(process);
		t.Name            = "Kernel";
		t.Status          = ThreadStatus.Active;
		t.SetKernelStack();

		/* Idle task */
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
		_resources   = new List!Resource();

		Task.Processes.Add(this);
	}

	/* Clone other._process to this process and ot to this process */
	this(Thread other) {
		this();
		_uid      = other.ParentProcess._uid;
		_gid      = other.ParentProcess._gid;
		_isKernel = other.ParentProcess._isKernel;
		_parent   = other.ParentProcess;
		_paging   = new Paging(other.ParentProcess._paging);
		_cwd      = other.ParentProcess._cwd;

		foreach (x; other.ParentProcess._resources) {
			if (x.AttachProcess(this))
                _resources.Add(x);
		}

		new Thread(this, other);
	}

	~this() {
		foreach (x; _resources) {
			if (x.DetachProcess(this))
				delete x;
		}

		foreach (x; _threads)
			delete x;

		delete _paging;
		delete _threads;
		delete _resources;
	}

	package ulong[] AllocUserStack(ulong size = Thread.UserStackSize) {
		for (ulong i = 0; i < size; i += Paging.PageSize) {
			_userStack -= Paging.PageSize;
			_paging.AllocFrame(_userStack, AccessMode.DefaultUser); //TODO: Nejako nefunguje :/
		}

		return (cast(ulong *)_userStack)[0 .. size];
	}
}