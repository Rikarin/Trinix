module FileSystem.ProcFS;

import System.Convert;
import System.DateTime;
import VFSManager.FSNode;
import VFSManager.FileNode;
import VFSManager.Partition;
import VFSManager.DirectoryNode;
import VFSManager.FileSystemProto;

import TaskManager.Task;


class ProcFS : FileSystemProto {
	this() { }

	static ProcFS Mount(DirectoryNode mountPoint) {
		if (mountPoint is null || !mountPoint.Mountpointable())
			return null;

		ProcFS ret = new ProcFS();
		ret.rootNode = new DirectoryNode("/", ret);
		ret.Identifier = "ProcFS";
		ret.rootNode.SetParent(mountPoint);
		
		//ret.rootNode.AddNode(new DirectoryNode("current", ret));

		mountPoint.Mount(ret.rootNode);
		return ret;
	}

	override bool Unmount() { return true; }
	override Partition GetPartition() { return null; }

	override bool SetName(FSNode node, string name) { return false; }
	override bool SetPermissions(FSNode node, uint perms) { return false; }
	override bool SetUID(FSNode node, ulong uid) { return false; }
	override bool SetGID(FSNode node, ulong gid) { return false; }
	override bool SetParent(FSNode node, DirectoryNode parent) { return false; }

	override bool SetCreateTime(FSNode node, DateTime time) { return false; }
	override bool SetModifyTime(FSNode node, DateTime time) { return false; }
	override bool SetAccessTime(FSNode node, DateTime time) { return false; }

	override FileNode CreateFile(DirectoryNode parent, string name) { return null; }
	override DirectoryNode CreateDirectory(DirectoryNode parent, string name) { return null; }
	override bool Remove(DirectoryNode parent, FSNode node) { return false; }


	override bool LoadContent(DirectoryNode dir) {
		dir.IsLoaded = true;

		if (dir is rootNode)			
			LoadProcesses();
		else if (dir.Parent == rootNode) //&& is number
			LoadFileDesciptors(dir);

		return true;
	}

	override ulong Read(FileNode file, ulong offset, byte[] data) {
		return 0;
	}

	override ulong Write(FileNode file, ulong offset, byte[] data) {
		return 0;
	}


private:
	void LoadFileDesciptors(DirectoryNode processDir) {
		auto fd = processDir.GetChild("fd");

		if (fd is null) {
			fd = new DirectoryNode("fd", this);
			processDir.AddNode(fd);
		}

		/*auto pfd = Task.GetAllProcesses[Convert.ToInt64(processDir.Name)].FileDescriptors;
		for (long i; i < pfd.Count; i++) {
			string name = Convert.ToString(i);
			auto child = rootNode.GetChild(name);

			if (child is null)
				rootNode.AddNode(new DirectoryNode(name, this));
		}*/
	}

	void LoadProcesses() {
		foreach (x; Task.GetAllProcesses) {
			string name = Convert.ToString(x.ID);
			auto child = rootNode.GetChild(name);

			if (child is null)
				rootNode.AddNode(new DirectoryNode(name, this));
		}
	}
}