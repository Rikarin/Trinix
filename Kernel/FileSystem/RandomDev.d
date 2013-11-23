module FileSystem.RandomDev;

import Devices;
import VFSManager;
import System.IO;


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