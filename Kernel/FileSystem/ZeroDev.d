module FileSystem.ZeroDev;

import VFSManager.CharNode;
import VFSManager.DirectoryNode;
import System.IO.FileAttributes;


class ZeroDev : CharNode {
	this(string name) {
		super(NewAttributes(name));
	}

	override ulong Read(ulong offset, byte[] data) {
		data[0] = 0;
		return 1;
	}

	override ulong Write(ulong offset, byte[] data) {
		return 0;
	}
}