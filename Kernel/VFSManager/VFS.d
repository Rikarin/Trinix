module VFSManager.VFS;

import Core.Log;
import Core.DeviceManager;
import VFSManager.FSNode;
import VFSManager.PipeNode;
import VFSManager.DirectoryNode;
import TaskManager.Task;
import SyscallManager.Res;

import FileSystem.DevFS;
import FileSystem.TmpFS;
import FileSystem.ProcFS;
import FileSystem.NullDev;
import FileSystem.ZeroDev;
import FileSystem.PipeDev;
import FileSystem.HelloDev;
import FileSystem.RandomDev;
import FileSystem.SerialDev;

import Devices.TTY;
import Devices.Port.SerialPort;

import System.IFace;
import System.String;
import System.IO.FileAttributes;


class VFS {
public:
static:
	private __gshared DirectoryNode root;

	@property DirectoryNode RootNode() { return root; }


	bool Init() {
		root = new DirectoryNode(null, FSNode.NewAttributes("/"));
		TmpFS.Mount(root);
		Log.Result(true);

		Log.Print(" - Mounting DevFS");
		DeviceManager.DevFS = CreateDirectory("dev");
		DevFS.Mount(DeviceManager.DevFS);

		DeviceManager.DevFS.AddNode(new NullDev("null"));
		DeviceManager.DevFS.AddNode(new ZeroDev("zero"));
		DeviceManager.DevFS.AddNode(new HelloDev("hello"));
		DeviceManager.DevFS.AddNode(new RandomDev("random"));
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

	private bool Parse(ref string path, ref DirectoryNode dir) {
		if (dir is null)
			dir = root;

		if (Find(path, dir))
			return false;

		string name = path[String.LastIndexOf(path, '/') + 1 .. $];
		if (String.LastIndexOf(path, '/') != -1) {
			string p = path[0 .. String.LastIndexOf(path, '/')];
			dir      = cast(DirectoryNode)Find(p, dir);
		}

		if (dir is null)
			return false;

		path = name;
		return true;
	}

	FSNode CreateFile(string path, DirectoryNode dir = null) {
		if (!Parse(path, dir))
			return null;

		if (dir.GetAttributes().Type & (FileType.Directory | FileType.Mountpoint))
			return cast(DirectoryNode)(cast(DirectoryNode)dir).Create(FileType.File, FSNode.NewAttributes(path));

		return null;
	}

	DirectoryNode CreateDirectory(string path, DirectoryNode dir = null) {
		if (!Parse(path, dir))
			return null;

		if (dir.GetAttributes().Type & (FileType.Directory | FileType.Mountpoint))
			return cast(DirectoryNode)(cast(DirectoryNode)dir).Create(FileType.Directory, FSNode.NewAttributes(path));

		return null;
	}

	PipeNode CreatePipe(string path, DirectoryNode dir = null, ulong size = 0x1000) {
		if (!Parse(path, dir))
			return null;

		if (dir.GetAttributes().Type & (FileType.Directory | FileType.Mountpoint)) {
			auto ret = new PipeDev(path, size);
			(cast(DirectoryNode)dir).AddNode(ret);
			return ret;
		}

		return null;
	}

	//CreateSymLink(string path, DirecotyNode dir = null)

	bool Remove(FSNode node) {
		FSNode parent = node.Parent;
		if (parent is null)
			return false;

		if (parent.Type & (FileType.Directory | FileType.Mountpoint))
			return (cast(DirectoryNode)parent).Remove(node);

		return false;
	}


//Syscall
	public static ulong SCall(ulong[] params) {
		if (params is null || !params.length)
			return ~0UL;

		final switch (params[0]) {
			case IFace.VFS.S_FIND:
				FSNode ret = VFS.Find(*cast(string *)params[1], params.length >= 3 ? cast(DirectoryNode)Res.GetByID(params[2], IFace.FSNode.OBJECT) : null);
				return ret is null ? 0 : ret.ResID();

			case IFace.VFS.S_MK_DIR:
				DirectoryNode ret = VFS.CreateDirectory(*cast(string *)params[1], params.length >= 3 ? cast(DirectoryNode)Res.GetByID(params[2], IFace.FSNode.OBJECT) : null);
				return ret is null ? 0 : ret.ResID();

			case IFace.VFS.S_MK_FILE:
				FSNode ret = VFS.CreateFile(*cast(string *)params[1], params.length >= 3 ? cast(DirectoryNode)Res.GetByID(params[2], IFace.FSNode.OBJECT) : null);
				return ret is null ? 0 : ret.ResID();

			case IFace.VFS.S_MK_PIPE:
				PipeNode ret = VFS.CreatePipe(*cast(string *)params[1], params.length >= 3 ? cast(DirectoryNode)Res.GetByID(params[2], IFace.FSNode.OBJECT) : null);
				return ret is null ? 0 : ret.ResID();

			case IFace.VFS.S_CREATE_TTY:
				if (params.length < 3)
					return ~0UL;

				//PTYDev master;
				//TTYDev slave;
				//new TTY(master, slave);
				//*cast(ulong *)params[1] = master.ResID();
				//*cast(ulong *)params[2] = slave.ResID();
				return 0;

			case IFace.VFS.S_GET_RFN:
				return VFS.RootNode.ResID();

			case IFace.VFS.S_GET_CWD:
				return Task.CurrentProcess.GetCWD().ResID();
		}

		return ~0UL;
	}
}