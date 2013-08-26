module VFS.CharNode;

import VFS.FSNode;
import VFS.DirectoryNode;


abstract class CharNode : FSNode {
	override @property FSType Type() { return FSType.CHARDEVICE; }

	this(string name) {
		this.perms  = 0xFFFF;
		this.name   = name;
	}

	long Read(ulong start, out byte[] data);
	long Write(ulong start, in byte[] data);
}