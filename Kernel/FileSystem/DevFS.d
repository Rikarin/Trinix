module FileSystem.DevFS;

import VFSManager;
import System.IO;


class DevFS : FileSystemProto {
	private this() { }
	override bool Unmount() { return true; }
	override bool LoadContent(DirectoryNode dir) { return true; }
	override Partition GetPartition() { return null; }
	override FileAttributes GetAttributes(FSNode node) { return node.GetAttributes(); }
	override void SetAttributes(FSNode node, FileAttributes fileAttributes) { node.SetAttributes(fileAttributes); }
	override ulong Read(FileNode file, ulong offset, byte[] data) { return 0; }
	override ulong Write(FileNode file, ulong offset, byte[] data) { return 0; }


	static DevFS Mount(DirectoryNode mountPoint) {
		if (mountPoint && !mountPoint.Mountpointable())
			return null;

		auto ret = new DevFS();
		ret.isWritable = true;
		ret.rootNode = new DirectoryNode(ret, FSNode.NewAttributes("/"));
		ret.Identifier = "DevFS";

		mountPoint.Mount(ret.rootNode);
		return ret;
	}

	override FSNode Create(DirectoryNode parent, FileType type, FileAttributes fileAttributes) {
		if (type == FileType.Directory) {
			auto ret = new DirectoryNode(this, fileAttributes);
			parent.AddNode(ret);
			return ret;
		}

		return null;
	}

	override bool Remove(DirectoryNode parent, FSNode node) {
		if (node.GetAttributes().Type == FileType.Directory) {
			if (!(cast(DirectoryNode)node).Childrens.Count)
				return true;
		}

		return false;
	}
}