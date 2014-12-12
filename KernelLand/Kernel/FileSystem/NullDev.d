module FileSystem.NullDev;

import VFSManager;


final class NullDev : CharNode {
	this(DirectoryNode parent, string name) {
		super(parent, NewAttributes(name));
	}

	override ulong Read(long offset, byte[] data) {
		return 0;
	}

	override ulong Write(long offset, byte[] data) {
		return 0;
	}
}