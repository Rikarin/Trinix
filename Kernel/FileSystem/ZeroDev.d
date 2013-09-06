module FileSystem.ZeroDev;

import VFSManager.CharNode;
import VFSManager.DirectoryNode;


class ZeroDev : CharNode {
	this(string name = "zero") { 
		super(name);
	}

	override long Read(ulong offset, byte[] data) {
		data[0] = 0;
		return 1;
	}

	override long Write(ulong offset, byte[] data) {
		return 0;
	}
}