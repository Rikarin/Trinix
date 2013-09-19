module FileSystem.ZeroDev;

import VFSManager.CharNode;
import VFSManager.DirectoryNode;


class ZeroDev : CharNode {
	this(string name = "zero") { 
		super(name);
	}

	override ulong Read(ulong offset, byte[] data) {
		data[0] = 0;
		return 1;
	}

	override ulong Write(ulong offset, byte[] data) {
		return 0;
	}
}