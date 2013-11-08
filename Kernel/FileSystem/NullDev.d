module FileSystem.NullDev;

import VFSManager.CharNode;
import VFSManager.DirectoryNode;
import System.IO.FileAttributes;


class NullDev : CharNode {
	this(string name) {
		super(NewAttributes(name));
	}

	override ulong Read(ulong offset, byte[] data) {
		return 0;
	}

	override ulong Write(ulong offset, byte[] data) {
		return 0;
	}
}