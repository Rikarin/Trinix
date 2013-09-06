module FileSystem.NullDev;

import VFSManager.CharNode;
import VFSManager.DirectoryNode;


class NullDev : CharNode {
	this(string name = "null") { 
		super(name);
	}

	override long Read(ulong offset, byte[] data) {
		return 0;
	}

	override long Write(ulong offset, byte[] data) {
		return 0;
	}
}