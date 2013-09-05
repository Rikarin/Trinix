module TaskManager.Process;

import VFS.FSNode;
import VFS.DirectoryNode;
import SyscallManager.Resource;
import TaskManager.Thread;
import TaskManager.Task;
import Architectures.Paging;

import System.Collections.Generic.All;


class Process /*: Resource*/ {
private:
	this() { }

package:
	ulong id; //unique ID for each process
	Process parent;
	State state;

	string name;
	string description;
	string cmdline;
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

		ret.descriptors = new List!(FSNode)();
		//ret.threads     = new List!(Thread)();

		//add descriptors... todo
		//ret.threads.Add(new Thread());

		return ret;
	}
}