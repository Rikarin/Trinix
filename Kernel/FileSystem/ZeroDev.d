module FileSystem.ZeroDev;

import VFSManager;
import System.IO;


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