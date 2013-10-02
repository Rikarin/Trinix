module VFSManager.VFS;

import Core.Log;
import Core.DeviceManager;
import VFSManager.FSNode;
import VFSManager.DirectoryNode;

import FileSystem.TmpFS;
import FileSystem.ProcFS;
import FileSystem.SerialDev;
import Devices.Port.SerialPort;
import System.String;


class VFS {
public:
static:
	private __gshared DirectoryNode root;

	@property DirectoryNode RootNode() { return root; }


	bool Init() {
		root = new DirectoryNode("/", null);
		Log.Result(true);

		Log.Print(" - Setting up DevFS");
		VFS.root.AddNode(DeviceManager.DevFS);
		Log.Result(true);

		Log.Print(" - Mounting TmpFS");
		TmpFS.Mount(VFS.root.CreateDirectory("tmp"));
		Log.Result(true);

		Log.Print(" - Mounting ProcFS");
		ProcFS.Mount(VFS.root.CreateDirectory("proc"));
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

	FSNode Find(string path, DirectoryNode dir = null) {
		FSNode node = dir is null ? root : dir;
		auto p = String.Split(path, '/');

		if (p[0] is null)
			node = root;

		foreach (x; p[1 .. $]) {
			if (x == "..")
				node = node.Parent;
			else if (x !is null && x != ".") {
				if (node.Type == FSType.DIRECTORY)
					node = (cast(DirectoryNode)node).GetChild(x);
				else
					node = null;
			}

			if (node is null)
				return null;
		}

		return node;
	}

	string Path(FSNode node) {
		string path;

		while (node !is null) {
			string t = "/" ~ node.Name;

			if (t != "//") {
				t = t ~ path;
				path = t;
			}
			node = node.Parent;
		}

		if (path is null)
			return "/";

		return path;
	}

	FSNode CreateFile(string path, DirectoryNode dir = null) {
		if (dir is null)
			dir = root;

		if (Find(path, dir))
			return null;

		auto p = String.Split(path, '/');
		string name = p[p.Count - 1];
		p.RemoveAt(p.Count - 1);

		string s = ".";
		foreach (x; p)
			s = s  ~ "/" ~ x;

		FSNode node = Find(s, dir);
		if (node is null)
			return null;

		if (node.Type & (FSType.DIRECTORY | FSType.MOUNTPOINT))
			return cast(FSNode)(cast(DirectoryNode)node).CreateFile(name);

		return null;
	}

	DirectoryNode CreateDirectory(string path, DirectoryNode dir = null) {
		if (dir is null)
			dir = root;

		if (Find(path, dir))
			return null;

		auto p = String.Split(path, '/');
		string name = p[p.Count - 1];
		p.RemoveAt(p.Count - 1);

		string s = ".";
		foreach (x; p)
			s = s  ~ "/" ~ x;

		FSNode node = Find(s, dir);
		if (node is null)
			return null;

		if (node.Type & (FSType.DIRECTORY | FSType.MOUNTPOINT))
			return (cast(DirectoryNode)node).CreateDirectory(name);

		return null;
	}
}