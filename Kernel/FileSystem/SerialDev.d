module FileSystem.SerialDev;

import VFSManager;
import TaskManager;
import Drivers.Port.SerialPort;

import System;
import System.IO;


class SerialDev : CharNode {
	private SerialPort dev;


	this(string name, SerialPort device) {
		super(NewAttributes(name));
		dev = device;
	}

	override ulong Read(ulong offset, byte[] data) {
		foreach(ref x; data) {
			while (!dev.Recieved()) 
				Task.Switch();
			
			x = dev.Read();
		}

		return data.length;
	}

	override ulong Write(ulong offset, byte[] data) {
		foreach (x; data)
			dev.Write(x);

		return data.length;
	}
}