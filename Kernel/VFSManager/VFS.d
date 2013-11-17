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
import System.IO.FileAttributes;


class VFS {
public:
static:
	private __gshared DirectoryNode root;

	@property DirectoryNode RootNode() { return root; }


	bool Init() {
		root = new DirectoryNode(null, FSNode.NewAttributes("/"));
		Log.Result(true);

		Log.Print(" - Setting up DevFS");
		VFS.root.AddNode(DeviceManager.DevFS);
		Log.Result(true);

		Log.Print(" - Mounting TmpFS");
		TmpFS.Mount(CreateDirectory("tmp"));
		Log.Result(true);

		Log.Print(" - Mounting ProcFS");
		ProcFS.Mount(CreateDirectory("proc"));
		Log.Result(false);

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
			Log.Print(x.GetAttributes().Name);

			switch (x.GetAttributes().Type) {
				case FileType.Directory:
					Log.Print("(D)");
					break;
				case FileType.Mountpoint:
					Log.Print("(M)");
					break;
				case FileType.Pipe:
					Log.Print("(P)");
					break;
				case FileType.CharDevice:
					Log.Print("(C)");
					break;
				case FileType.BlockDevice:
					Log.Print("(B)");
					break;
				case FileType.File:
					Log.Print("(F)");
					break;
				case FileType.Symlink:
					Log.Print("(S)");
					break;
				default:
					Log.Print("(ERROR)");
			}

			Log.Print("\n");

			if (x.GetAttributes().Type & (FileType.Directory | FileType.Mountpoint))
				PrintTree(cast(DirectoryNode)x, p + 1);
		}
	}

	FSNode Find(string path, DirectoryNode dir = null) {
		FSNode node = dir is null ? root : dir;
		auto p = String.Split(path, '/');

		if (p[0] is null)
			node = root;

		foreach (x; p) {
			if (x == "..")
				node = node.Parent;
			else if (x !is null && x != "." && x != "") {
				if (node.GetAttributes().Type & (FileType.Directory | FileType.Mountpoint))
					node = (cast(DirectoryNode)node).GetChild(x);
				else
					return null;
			}
		}

		return node;
	}

	string Path(FSNode node) {
		string path;

		while (node !is null) {
			string t = "/" ~ node.GetAttributes().Name;

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

		if (node.GetAttributes().Type & (FileType.Directory | FileType.Mountpoint))
			return cast(FSNode)(cast(DirectoryNode)node).Create(FileType.File, FSNode.NewAttributes(name));

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

		if (node.GetAttributes().Type & (FileType.Directory | FileType.Mountpoint))
			return cast(DirectoryNode)(cast(DirectoryNode)node).Create(FileType.Directory, FSNode.NewAttributes(name));

		return null;
	}

	bool Remove(FSNode node) {
		FSNode parent = node.Parent;
		if (parent is null)
			return false;

		if (parent.Type & (FileType.Directory | FileType.Mountpoint))
			return (cast(DirectoryNode)parent).Remove(node);

		return false;
	}
}