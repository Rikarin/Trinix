module FileSystem.RandomDev;

import VFSManager.CharNode;
import VFSManager.DirectoryNode;
import Devices.Random;
import System.IO.FileAttributes;


class RandomDev : CharNode {
	this(string name) {
		super(NewAttributes(name));
		attribs.Length = 1024;
	}

	override ulong Read(ulong offset, byte[] data) {
		foreach (ref x; data)
			x = Random.Number & 0xFF;

		return data.length;
	}

	override ulong Write(ulong offset, byte[] data) {
		return 0;
	}
}