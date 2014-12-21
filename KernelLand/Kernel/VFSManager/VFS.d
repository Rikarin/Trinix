/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module VFSManager.VFS;

import Core;
import Library;
import FileSystem;
import VFSManager;
import ObjectManager;
import MemoryManager;
import SyscallManager;


struct FSDriver {
	string Name;
	bool function(Partition partition) Detect;
	IFileSystem function(DirectoryNode mountpoint, Partition partition) Mount;
}


abstract final class VFS {
	private __gshared DirectoryNode _root;
	private __gshared LinkedList!FSDriver _drivers;

	@property static DirectoryNode Root() {
		return _root;
	}

	static void Initialize() {
		_drivers = new LinkedList!FSDriver();

		_root = new DirectoryNode(null, FSNode.NewAttributes("/"));
		DirectoryNode system = new DirectoryNode(_root, FSNode.NewAttributes("System"));

		DeviceManager.DevFS = new DirectoryNode(system, FSNode.NewAttributes("Devices"));
		DevFS.Mount(DeviceManager.DevFS);
		TmpFS.Mount(new DirectoryNode(system, FSNode.NewAttributes("Temporary")));

		new NullDev(DeviceManager.DevFS, "null");
		new ZeroDev(DeviceManager.DevFS, "zero");
		new RandomDev(DeviceManager.DevFS, "random");

        ResourceManager.AddCallTable(FSNode._rcs);
	}

    static void Finalize() {
        foreach (x; _drivers)
            delete x;

        delete _drivers;
    }

	static T Find(T)(string path, DirectoryNode start = null) {
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

		return cast(T)node;
	}

	debug static void PrintTree(DirectoryNode path, long p = 1) {
		foreach (x; path.Childrens) {
			foreach (i; 0 .. p)
				Logger.Write(" ");
			
            Logger.Write("- ");
            Logger.Write(x.Value.Attributes.Name);
			
			switch (x.Value.Attributes.Type) {
				case FileType.Directory:
                    Logger.Write("(D)");
					break;
				case FileType.Mountpoint:
                    Logger.Write("(M)");
					break;
				case FileType.Pipe:
                    Logger.Write("(P)");
					break;
				case FileType.CharDevice:
                    Logger.Write("(C)");
					break;
				case FileType.BlockDevice:
                    Logger.Write("(B)");
					break;
				case FileType.File:
                    Logger.Write("(F)");
					break;
				case FileType.SymLink:
                    Logger.Write("(S)");
					break;
				default:
                    Logger.Write("(ERROR)");
			}
            Logger.Write("\n");
			
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

	static IFileSystem Mount(lazy DirectoryNode mountpoint, Partition partition, string fsName) {
		FSDriver drv = GetFSDriver(fsName);
		if (drv == cast(FSDriver)null)
			return null;

		if (!drv.Detect(partition))
			return null;

		return drv.Mount(mountpoint, partition);
	}

    /* TODO: implenet flags... */
    static void MapIn(FSNode node, v_addr start, size_t length, ulong offset) {
        for (v_addr i = start; i < start + length; i += Paging.PAGE_SIZE)
            VirtualMemory.KernelPaging.AllocFrame(i, AccessMode.DefaultKernel);

        node.Read(offset, (cast(byte *)start)[0 .. length]);
    }
}