module VFS.PipeNode;

import VFS.FSNode;
import VFS.DirectoryNode;


abstract class PipeNode : FSNode {
	override @property FSType Type() { return FSType.PIPE; }

	this(string name) {
		this.perms  = 0xFFFF;
		this.name   = name;
	}

	void Open();
	void Close();
	long Read(ulong start, out byte[] data);
	long Write(ulong start, in byte[] data);

	//Syscalls
	override bool Accesible() { return true; }
}