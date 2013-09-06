module VFSManager.CharNode;

import VFSManager.FSNode;
import VFSManager.DirectoryNode;


abstract class CharNode : FSNode {
	override @property FSType Type() { return FSType.CHARDEVICE; }

	this(string name) {
		this.perms  = 0b110100100;
		this.name   = name;
	}

	//Syscalls
	override bool Accesible() { return true; }
}