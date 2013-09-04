module VFS.PipeNode;

import VFS.FSNode;
import VFS.DirectoryNode;


abstract class PipeNode : FSNode {
	override @property FSType Type() { return FSType.PIPE; }

	this(string name) {
		this.perms  = 0b110100100;
		this.name   = name;
	}

	void Open();
	void Close();

	//Syscalls
	override bool Accesible() { return true; }
}