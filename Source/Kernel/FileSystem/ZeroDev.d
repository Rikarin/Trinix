module FileSystem.ZeroDev;

import VFSManager;


public final class ZeroDev : CharNode {
	public this(DirectoryNode parent, string name) {
		super(parent, NewAttributes(name));
	}
	
	public override ulong Read(long offset, byte[] data) {
		if (data.length < 1)
			return 0;

		data[0] = 1;
		return 1;
	}
	
	public override ulong Write(long offset, byte[] data) {
		return 0;
	}
}