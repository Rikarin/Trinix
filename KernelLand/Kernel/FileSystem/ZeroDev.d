module FileSystem.ZeroDev;

import VFSManager;


final class ZeroDev : CharNode {
	this(DirectoryNode parent, string name) {
		super(parent, NewAttributes(name));
	}
	
	override ulong Read(long offset, byte[] data) {
		if (data.length < 1)
			return 0;

		data[0] = 1;
		return 1;
	}
	
	override ulong Write(long offset, byte[] data) {
		return 0;
	}
}