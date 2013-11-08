module FileSystem.ProcFS;

import TaskManager.Task;
import VFSManager.FSNode;
import VFSManager.FileNode;
import VFSManager.Partition;
import VFSManager.DirectoryNode;
import VFSManager.FileSystemProto;

import System.Convert;
import System.DateTime;
import System.IO.FileAttributes;


class ProcFS : FileSystemProto {
	private this() { }
	override bool Unmount() { return true; }
	override Partition GetPartition() { return null; }

	static ProcFS Mount(DirectoryNode mountPoint) {
		if (mountPoint is null || !mountPoint.Mountpointable())
			return null;

		ProcFS ret = new ProcFS();
		ret.rootNode = new DirectoryNode(ret, FSNode.NewAttributes("/"));
		ret.Identifier = "ProcFS";
		//ret.rootNode.SetParent(mountPoint); TODO
		mountPoint.Mount(ret.rootNode);

		return ret;
	}

	override ulong Read(FileNode file, ulong offset, byte[] data) { return 0; }
	override ulong Write(FileNode file, ulong offset, byte[] data) { return 0; }
	override FSNode Create(DirectoryNode parent, FileType type, FileAttributes fileAttributes) { return null; }
	override bool Remove(DirectoryNode parent, FSNode node) { return false; }

	override bool LoadContent(DirectoryNode dir) {
		dir.IsLoaded = true;

		if (dir is rootNode)			
			LoadProcesses();
		//else if (dir.Parent == rootNode) //&& is number
		//	LoadFileDesciptors(dir);

		return true;
	}


private:
	void LoadFileDesciptors(DirectoryNode processDir) {
		auto fd = processDir.GetChild("fd");

		if (fd is null) {
			fd = new DirectoryNode(this, FSNode.NewAttributes("fd"));
			processDir.AddNode(fd);
		}

		//auto pfd = Task.GetAllProcesses[Convert.ToInt64(processDir.Name)].FileDescriptors;
		//for (long i; i < pfd.Count; i++) {
		//	string name = Convert.ToString(i);
		//	auto child = fd.GetChild(name);

		//	if (child is null)
		//		fd.AddNode(new DirectoryNode(name, this));
		//}
	}

	void LoadProcesses() {
		foreach (x; Task.GetAllProcesses) {
			string name = Convert.ToString(x.ID);
			auto child = rootNode.GetChild(name);

			if (child is null)
				rootNode.AddNode(new DirectoryNode(this, FSNode.NewAttributes(name)));
		}
	}
}