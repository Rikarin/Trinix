module FileSystem.ZeroDev;

import VFS.CharNode;
import VFS.DirectoryNode;


class ZeroDev : CharNode {
	this(string name = "zero") { 
		super(name);
	}

	override long Read(ulong start, out byte[] data) {
		data[0] = 0;
		return 1;
	}

	override long Write(ulong start, in byte[] data) {
		return 0;
	}
}