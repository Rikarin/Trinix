module TaskManager.Process;

import Core.DeviceManager;
import Architectures.Paging;

import VFSManager.VFS;
import VFSManager.FSNode;
import VFSManager.DirectoryNode;

import TaskManager.Task;
import TaskManager.Thread;
import TaskManager.Signal;

import SyscallManager.Res;
import SyscallManager.Resource;

import System.IFace;
import System.Collections.Generic.List;
import System.Diagnostics.ProcessStartInfo;
import System.Diagnostics.Process : SigNum;
import System.Convert;


class Process : Resource {
private:
	this() {
		const CallTable[] callTable = [
			{IFace.Process.SET_FD,      &SC_SetFD},
			{IFace.Process.GET_FD,      &SC_GetFD},
			{IFace.Process.SEND_SIGNAL, &SC_SendSignal},
			{IFace.Process.SET_HANDLER, &SC_SetHandler},
		];

		super(IFace.Process.OBJECT, callTable);
	}


package:
	ulong id; //unique ID for each process
	Process parent;
	State state;
	uint mask;
	ulong retval;

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
	Convert.DelegateToLong Signals[Signal.Count];

	enum State : ubyte {
		Zombie,
		Running,
		Stopped
	}

	
	@property ulong ID() { return id; }
	@property List!(FSNode) FileDescriptors() { return descriptors; }

	DirectoryNode GetCWD() { return cwd; }
	void SetCWD(DirectoryNode value) { cwd = value; }

	void UnregisterFD(FSNode fd) { descriptors.Remove(fd); }
	ulong RegisterFD(FSNode fd) {
		descriptors.Add(fd);
		return descriptors.IndexOf(fd);
	}


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

		Thread t = new Thread();
		t.id = Task.NewTID();
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
	static Process CreateProcess(long function(ulong*) ThreadEntry, string[] args = null) {
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


		/** Send arguments to main thread */
		string[] a = new string[args.length];
		if (args !is null)
			a[] = args[0 .. $];

		ulong* x = (new ulong[2]).ptr;
		x[0] = cast(ulong)a.ptr;
		x[1] = a.length;

		Thread t = new Thread(cast(void function(ulong*))ThreadEntry, cast(void *)x, ret);
		Task.Procs.Add(ret);
		return ret;
	}


//Syscalls
	ulong SCall(ulong[] params) {
		if (params is null || !params.length)
			return ~0UL;

		switch (params[0]) {
			//case IFace.Process.GET_PID:
			//	return Task.CurrentProcess.id;

			case IFace.Process.CURRENT:
				return Task.CurrentProcess.ResID();

			case IFace.Process.SWITCH:
				Task.Switch();
				break;
			case IFace.Process.S_CREATE:
				if (params.length < 2)
					return ~0UL;

				ProcessStartInfo start = *cast(ProcessStartInfo *)params[1];

				Process ret     = new Process();
				ret.parent      = Task.CurrentProcess;
				ret.id          = Task.NewPID();
				ret.name        = start.FileName;
				ret.description = start.Description;

				ret.mask        = 0x12; //022 in oct
				ret.paging      = Paging.KernelPaging;
				ret.cwd         = VFS.RootNode;
				ret.state       = State.Running;
				ret.cmdline     = start.Arguments;

				ret.descriptors = new List!FSNode();
				ret.threads     = new List!Thread();
				ret.signalQueue = new List!SigNum();

				/** Add descriptors */
				foreach (x; start.FileDescriptors)
					ret.descriptors.Add(cast(FSNode)Res.GetByID(x.id, IFace.FSNode.OBJECT));


				/** Send arguments to main thread */
				string[] a = new string[start.Arguments.length];
				if (start.Arguments !is null)
					a[] = start.Arguments[0 .. $];

				ulong* x = (new ulong[2]).ptr;
				x[0] = cast(ulong)a.ptr;
				x[1] = a.length;

				Thread t = new Thread(cast(void function(ulong*))start.ThreadEntry, cast(void *)x, ret);
				Task.Procs.Add(ret);
				return ret.ResID();
				break;

			default:
		}

		return ~0UL;
	}

private:
	ulong SC_SendSignal(ulong[] params) {
		if (params is null || !params.length)
			return ~0UL;

		if (params[0] > Signal.Count)
			return ~0UL;

		signalQueue.Add(cast(SigNum)params[0]);
		return 0;
	}

	ulong SC_SetHandler(ulong[] params) {
		if (params is null || params.length < 3)
			return ~0UL;

		if (params[0] > Signal.Count)
			return ~0UL;

		Signals[params[0]].Value1 = params[1];
		Signals[params[0]].Value2 = params[2];
		return 0;
	}

	ulong SC_SetFD(ulong[] params) {
		if (params is null || params.length < 1)
			return ~0UL;

		FSNode fd = cast(FSNode)Res.GetByID(params[0], IFace.FSNode.OBJECT);
		return RegisterFD(fd);
	}

	ulong SC_GetFD(ulong[] params) {
		if (params is null || params.length < 1 || params[0] >= FileDescriptors.Count)
			return ~0UL;

		return FileDescriptors[params[0]].ResID();
	}
}