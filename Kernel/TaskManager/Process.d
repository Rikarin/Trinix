module TaskManager.Process;

import VFSManager.VFS;
import VFSManager.FSNode;
import VFSManager.DirectoryNode;
import SyscallManager.Resource;
import TaskManager.Task;
import TaskManager.Thread;
import TaskManager.Signal;
import Architectures.Paging;
import Core.DeviceManager;
import SyscallManager.Res;
import System.IFace;

import System.Collections.Generic.List;


class Process : Resource {
private:
	this() { super(0, null); }

package:
	ulong id; //unique ID for each process
	Process parent;
	State state;
	uint mask;

	string name;
	string description;
	string[] cmdline;
	ulong uid;

	DirectoryNode cwd;
	Paging paging;
	List!Thread threads;
	List!FSNode descriptors;

	public List!SigNum signalQueue;
	SignalState signalState;
	ulong* signalStack;


public:
	void function() Signals[Signal.Count];

	enum State : ubyte {
		Zombie,
		Running,
		Stopped
	}

	
	DirectoryNode GetCWD() { return cwd; }
	void SetCWD(DirectoryNode value) { cwd = value; }

	void RegisterFD(FSNode fd) { descriptors.Add(fd); }
	void UnregisterFD(FSNode fd) { descriptors.Remove(fd); }


	static Process Init() {
		if (Task.Threads.Count)
			return null;

		Process ret     = new Process();
		ret.id          = Task.NewPID();
		ret.name        = "Init";
		ret.description = "Shit happens...";
		ret.mask        = 0x12; //022 in oct
		ret.paging      = Paging.KernelPaging;
		ret.cwd         = VFS.RootNode;
		ret.state       = State.Running;

		ret.descriptors = new List!FSNode();
		ret.threads     = new List!Thread();
		ret.signalQueue = new List!SigNum();


		ret.descriptors.Add(DeviceManager.DevFS.Childrens[0]); //keyboard stdin

		Thread t = new Thread();
		t.parent = ret;
		t.state = Thread.State.Running;
		t.kernelStack = (new ulong[Thread.STACK_SIZE]).ptr;
		t.SetKernelStack();
		ret.threads.Add(t);

		Task.Procs.Add(ret);
		Task.Threads.Add(t);

		return ret;
	}


	//for testing only
	static Process CreateProcess(void function() ThreadEntry, string[] args = null) {
		Process ret     = new Process();
		ret.parent      = Task.CurrentProcess;
		ret.id          = Task.NewPID();
		ret.name        = "testing process";
		ret.description = "Shit happens...";
		ret.mask        = 0x12; //022 in oct
		ret.paging      = Paging.KernelPaging;
		ret.cwd         = VFS.RootNode;
		ret.state       = State.Running;
		ret.cmdline     = args;

		ret.descriptors = new List!FSNode();
		ret.threads     = new List!Thread();
		ret.signalQueue = new List!SigNum();


		//ret.descriptors.Add(DeviceManager.DevFS.Childrens[0]); //keyboard stdin

		Thread t = new Thread(ThreadEntry, cast(void *)&args);
		t.parent = ret;
		t.state = Thread.State.Running;
		t.kernelStack = (new ulong[Thread.STACK_SIZE]).ptr;
		ret.threads.Add(t);

		Task.Procs.Add(ret);
		Task.Threads.Add(t);

		return ret;
	}


//Syscalls
	override bool Accessible() { return true; }

	static ulong SCall(ulong[] params) {
		if (params is null || !params.length)
			return ~0UL;

		switch (params[0]) {
			case IFace.Process.S_SEND_SIGNAL:
				if (params.length < 3)
					return ~0UL;

				Process proc = cast(Process)Res.GetByID(params[1], IFace.Process.OBJECT);
				if (proc is null)
					return ~0UL;

				if (params[2] > Signal.Count)
					return ~0UL;

				proc.signalQueue.Add(cast(SigNum)params[2]);
				break;

			case IFace.Process.S_SET_HANDLER:
				if (params.length < 4)
					return ~0UL;

				Process proc = cast(Process)Res.GetByID(params[1], IFace.Process.OBJECT);
				if (proc is null)
					return ~0UL;

				if (params[2] > Signal.Count)
					return ~0UL;

				proc.Signals[params[2]] = cast(void function())params[3];
				break;

			default:
				return ~0UL;
		}

		return ~0UL;
	}
}