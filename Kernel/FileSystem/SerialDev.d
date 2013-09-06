module FileSystem.SerialDev;

import VFSManager.CharNode;
import VFSManager.DirectoryNode;
import Devices.Port.SerialPort;


class SerialDev : CharNode {
	private SerialPort dev;


	this(string name, SerialPort device) { 
		super(name);
		dev = device;
		//time... todo
	}

	override long Read(ulong offset, byte[] data) {
		foreach(ref x; data) {
			while (!dev.Recieved()) {} //Task.Switch... todo
			x = dev.Read();
		}

		return data.length;
	}

	override long Write(ulong offset, byte[] data) {
		foreach (x; data)
			dev.Write(x);

		return data.length;
	}
}