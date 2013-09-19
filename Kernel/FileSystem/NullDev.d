module FileSystem.NullDev;

import VFSManager.CharNode;
import VFSManager.DirectoryNode;


class NullDev : CharNode {
	this(string name = "null") { 
		super(name);
	}

	override ulong Read(ulong offset, byte[] data) {
		return 0;
	}

	override ulong Write(ulong offset, byte[] data) {
		return 0;
	}
}