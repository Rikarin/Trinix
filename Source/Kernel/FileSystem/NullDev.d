module FileSystem.NullDev;

import VFSManager;


public final class NullDev : CharNode {
	public this(DirectoryNode parent, string name) {
		super(parent, NewAttributes(name));
	}

	public override ulong Read(long offset, byte[] data) {
		return 0;
	}

	public override ulong Write(long offset, byte[] data) {
		return 0;
	}
}