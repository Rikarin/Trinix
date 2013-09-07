module TaskManager.Process;

import VFSManager.VFS;
import VFSManager.FSNode;
import VFSManager.DirectoryNode;
import SyscallManager.Resource;
import TaskManager.Task;
import TaskManager.Thread;
import Architectures.Paging;
import Core.DeviceManager;

import System.Collections.Generic.All;


class Process /*: Resource */{
private:
	this() {/*super(0, null);*/ }

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
	List!(Thread *) threads; //prerobit na ref todo
	List!(FSNode) descriptors;

public:
	enum State : ubyte {
		Zombie,
		Running,
		Stopped
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
		ret.cwd         = VFS.Root;

		ret.descriptors = new List!(FSNode)();
		ret.threads     = new List!(Thread *)();

		new List!(Thread)();
		new List!(Thread)();

		ret.descriptors.Add(DeviceManager.DevFS.Childrens[0]); //keyboard stdin
		ret.descriptors.Add(DeviceManager.DevFS.Childrens[1]); //tty stdout

		Thread t = new Thread();
		t.parent = ret;
		t.state = Thread.State.Running;
		t.kernelStack = (new byte[0x1000]).ptr;
		t.SetKernelStack();
		ret.threads.Add(&t);

		Task.Procs.Add(ret);
		Task.Threads.Add(t);

		return ret;
	}



//Syscalls
//	override bool Accesible() { return true; }
}