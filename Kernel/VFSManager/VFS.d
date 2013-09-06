module VFSManager.VFS;

import Core.Log;
import Core.DeviceManager;
import VFSManager.FSNode;
import VFSManager.DirectoryNode;

import FileSystem.SerialDev;
import Devices.Port.SerialPort;


class VFS {
public:
static:
	__gshared DirectoryNode Root;


	bool Init() {
		Root = new DirectoryNode("/", null);
		Log.Result(true);

		Log.Print(" - Setting up DevFS");
		VFS.Root.AddNode(DeviceManager.DevFS);
		Log.Result(true);

		Log.Print(" - Setting up serial devices ttyS0 - ttyS3");
		DeviceManager.DevFS.AddNode(new SerialDev("ttyS0", new SerialPort(SerialPort.COM1)));
		DeviceManager.DevFS.AddNode(new SerialDev("ttyS1", new SerialPort(SerialPort.COM2)));

		asm { cli; hlt; }

		new SerialDev("lol", new SerialPort(SerialPort.COM2));
		//DeviceManager.DevFS.AddNode(new SerialDev("ttyS2", new SerialPort(SerialPort.COM3)));
		//DeviceManager.DevFS.AddNode(new SerialDev("ttyS3", new SerialPort(SerialPort.COM4)));

		return true;
	}

	void PrintTree(DirectoryNode path, long p = 1) {
		foreach (x; path.Childrens) {
			foreach (i; 0 .. p)
				Log.Print(" ");
				
			Log.Print("- ");
			Log.Print(x.Name);
			Log.Print("\n");

			if (x.Type & (FSType.DIRECTORY | FSType.MOUNTPOINT))
				PrintTree(cast(DirectoryNode)x, p + 1);
		}
	}
}