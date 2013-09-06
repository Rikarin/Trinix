module TaskManager.Process;

import VFSManager.FSNode;
import VFSManager.DirectoryNode;
import SyscallManager.Resource;
import TaskManager.Thread;
import TaskManager.Task;
import Architectures.Paging;
import Core.DeviceManager;

import System.Collections.Generic.All;


class Process /*: Resource*/ {
private:
	this() { }

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
	List!(Thread) threads;
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

		ret.descriptors = new List!(FSNode)();
		//ret.threads     = new List!(Thread)();

		ret.descriptors.Add(DeviceManager.DevFS.Childrens[0]); //keyboard stdin
		ret.descriptors.Add(DeviceManager.DevFS.Childrens[1]); //tty stdout
		//ret.threads.Add(new Thread());

		return ret;
	}
}