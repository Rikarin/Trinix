module FileSystem.RandomDev;

import VFS.CharNode;
import VFS.DirectoryNode;
import Devices.Random;


class RandomDev : CharNode {
	this(string name = "random") { 
		super(name);
		length = 1024;
	}

	override long Read(ulong start, byte[] data) {
		foreach (ref x; data)
			x = Random.Number & 0xFF;

		return data.length;
	}

	override long Write(ulong start, byte[] data) {
		return data.length;
	}
}