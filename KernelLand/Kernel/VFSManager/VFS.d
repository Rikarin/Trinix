module VFSManager.VFS;

import Core;
import Library;
import FileSystem;
import VFSManager;
import ObjectManager;


struct FSDriver {
	string Name;
	bool function(Partition partition) Detect;
	IFileSystem function(DirectoryNode mountpoint, Partition partition) Mount;
}


abstract final class VFS : IStaticModule {
	private __gshared DirectoryNode _root;
	private __gshared LinkedList!FSDriver _drivers;

	@property static DirectoryNode Root() {
		return _root;
	}

	static bool Initialize() {
		_drivers = new LinkedList!FSDriver(); //TODO finalize

		_root = new DirectoryNode(null, FSNode.NewAttributes("/"));
		DirectoryNode system = new DirectoryNode(_root, FSNode.NewAttributes("System"));

		DeviceManager.DevFS = new DirectoryNode(system, FSNode.NewAttributes("Devices"));
		DevFS.Mount(DeviceManager.DevFS);
		TmpFS.Mount(new DirectoryNode(system, FSNode.NewAttributes("Temporary")));

		new NullDev(DeviceManager.DevFS, "null");
		new ZeroDev(DeviceManager.DevFS, "zero");
		new RandomDev(DeviceManager.DevFS, "random");

		return true;
	}

	static bool Install() {
		//TODO
		return true;
	}

	static FSNode Find(string path, DirectoryNode start = null) {
		FSNode node = start is null ? _root : start;
		scope List!string list = path.Split('/');

		if (list[0] is null)
			node = _root;

		foreach (x; list) {
			if (x == "..")
				node = node.Parent;
			else if (x !is null && x != "." && x != "") {
				if (node.Attributes.Type & (FileType.Directory | FileType.Mountpoint))
					node = (cast(DirectoryNode)node)[x];
				else
					return null;
			}
		}

		return node;
	}

	// only for debug use
	static void PrintTree(DirectoryNode path, long p = 1) {
		foreach (x; path.Childrens) {
			foreach (i; 0 .. p)
				Log.Write(" ");
			
			Log.Write("- ");
			Log.Write(x.Value.Attributes.Name);
			
			switch (x.Value.Attributes.Type) {
				case FileType.Directory:
					Log.Write("(D)");
					break;
				case FileType.Mountpoint:
					Log.Write("(M)");
					break;
				case FileType.Pipe:
					Log.Write("(P)");
					break;
				case FileType.CharDevice:
					Log.Write("(C)");
					break;
				case FileType.BlockDevice:
					Log.Write("(B)");
					break;
				case FileType.File:
					Log.Write("(F)");
					break;
				case FileType.SymLink:
					Log.Write("(S)");
					break;
				default:
					Log.Write("(ERROR)");
			}

			Log.NewLine();
			
			if (x.Value.Attributes.Type & (FileType.Directory | FileType.Mountpoint))
				PrintTree(cast(DirectoryNode)x.Value, p + 1);
		}
	}

	static void AddDriver(FSDriver driver) {
		if (_drivers.Contains(driver))
			return;

		_drivers.Add(driver);
	}

	static void RemoveDriver(string name) {
		_drivers.Remove(Array.Find(_drivers, (LinkedListNode!FSDriver o) => o.Value.Name == name));
	}

	static FSDriver GetFSDriver(string name) {
		auto drv = Array.Find(_drivers, (LinkedListNode!FSDriver o) => o.Value.Name == name);
		return drv !is null ? drv.Value : cast(FSDriver)null;
	}

	static IFileSystem Mount(DirectoryNode mountpoint, Partition partition, string fsName) {
		FSDriver drv = GetFSDriver(fsName);
		if (drv == cast(FSDriver)null)
			return null;

		if (!drv.Detect(partition))
			return null;

		return drv.Mount(mountpoint, partition);
	}
}