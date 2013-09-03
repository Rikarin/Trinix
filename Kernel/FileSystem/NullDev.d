module FileSystem.NullDev;

import VFS.CharNode;
import VFS.DirectoryNode;


class NullDev : CharNode {
	this(string name = "null") { 
		super(name);
	}

	override long Read(ulong start, byte[] data) {
		return 0;
	}

	override long Write(ulong start, byte[] data) {
		return 0;
	}
}