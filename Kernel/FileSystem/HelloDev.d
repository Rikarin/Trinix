module FileSystem.HelloDev;

import VFS.CharNode;
import VFS.DirectoryNode;


class HelloDev : CharNode {
	const string hello = "hello world";

	this(string name = "hello") { 
		super(name);
		length = 12;
	}

	override long Read(ulong start, out byte[] data) {
		foreach (long i, ref x; data)
			x = hello[start++ % 12];
			
		return data.length;
	}

	override long Write(ulong start, in byte[] data) {
		return data.length;
	}
}