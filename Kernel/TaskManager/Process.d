module TaskManager.Process;

import VFS.FSNode;
import VFS.DirectoryNode;
import SyscallManager.Resource;
import TaskManager.Thread;
import TaskManager.Task;

import System.Collections.Generic.All;


class Process /*: Resource*/ {
package:
	Process parent;
	ubyte state;
	long retval;

	string name;
	string description;
	string cmdline;
	ulong uid;

	DirectoryNode cwd;
	List!(Thread) threads;
	List!(FSNode) descriptors;

public:
	enum Status {
		Zombie,
		Running,
		Starting,
		Finished
	}


	this(uint a) { }

	static void Init() {
		if (Task.Threads.Count)
			return;
	}
}