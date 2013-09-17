module VFSManager.VFS;

import Core.Log;
import Core.DeviceManager;
import VFSManager.FSNode;
import VFSManager.DirectoryNode;

import FileSystem.TmpFS;
import FileSystem.ProcFS;
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

		Log.Print(" - Mounting TmpFS");
		TmpFS.Mount(VFS.Root.CreateDirectory("tmp"));
		Log.Result(true);

		Log.Print(" - Mounting ProcFS");
		ProcFS.Mount(VFS.Root.CreateDirectory("proc"));
		Log.Result(true);

		Log.Print(" - Setting up serial devices ttyS0 - ttyS3");
		DeviceManager.DevFS.AddNode(new SerialDev("ttyS0", new SerialPort(SerialPort.COM1)));
		DeviceManager.DevFS.AddNode(new SerialDev("ttyS1", new SerialPort(SerialPort.COM2)));
		DeviceManager.DevFS.AddNode(new SerialDev("ttyS2", new SerialPort(SerialPort.COM3)));
		DeviceManager.DevFS.AddNode(new SerialDev("ttyS3", new SerialPort(SerialPort.COM4)));

		return true;
	}

	void PrintTree(DirectoryNode path, long p = 1) {
		foreach (x; path.Childrens) {
			foreach (i; 0 .. p)
				Log.Print(" ");
				
			Log.Print("- ");
			Log.Print(x.Name);

			switch (x.Type) {
				case FSType.DIRECTORY:
					Log.Print("(D)");
					break;
				case FSType.MOUNTPOINT:
					Log.Print("(M)");
					break;
				case FSType.PIPE:
					Log.Print("(P)");
					break;
				case FSType.CHARDEVICE:
					Log.Print("(C)");
					break;
				case FSType.BLOCKDEVICE:
					Log.Print("(B)");
					break;
				case FSType.FILE:
					Log.Print("(F)");
					break;
				case FSType.SYMLINK:
					Log.Print("(S)");
					break;
				default:
					Log.Print("(ERROR)");
			}

			Log.Print("\n");

			if (x.Type & (FSType.DIRECTORY | FSType.MOUNTPOINT))
				PrintTree(cast(DirectoryNode)x, p + 1);
		}
	}
}