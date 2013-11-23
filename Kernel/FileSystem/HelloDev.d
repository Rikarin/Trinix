module FileSystem.HelloDev;

import VFSManager;
import System.IO;


class HelloDev : CharNode {
	const string hello = "hello world";

	this(string name) {
		super(NewAttributes(name));
		attribs.Length = 12;
	}

	override ulong Read(ulong offset, byte[] data) {
		foreach (ref x; data)
			x = hello[offset++ % 12];
			
		return data.length;
	}

	override ulong Write(ulong offset, byte[] data) {
		return data.length;
	}
}