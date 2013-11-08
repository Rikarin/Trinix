module FileSystem.TmpFS;

import System.DateTime;
import VFSManager.FSNode;
import VFSManager.FileNode;
import VFSManager.Partition;
import VFSManager.DirectoryNode;
import VFSManager.FileSystemProto;
import System.IO.FileAttributes;


class TmpFileNode : FileNode {
	private byte[] data;


	override FileAttributes GetAttributes() {
		attribs.Length = data.length;
		return attribs;
	}

	this(FileSystemProto fileSystem, FileAttributes fileAttributes) {
		super(fileSystem, fileAttributes);
	}

	~this() { delete data; }
}


class TmpFS : FileSystemProto {
	private this() { }
	override bool Unmount() { return true; }
	override bool LoadContent(DirectoryNode dir) { return true; }
	override Partition GetPartition() { return null; }


	static TmpFS Mount(DirectoryNode mountPoint) {
		if (mountPoint && !mountPoint.Mountpointable())
			return null;

		TmpFS ret = new TmpFS();
		ret.isWritable = true;
		ret.rootNode = new DirectoryNode(ret, FSNode.NewAttributes("/"));
		ret.Identifier = "TmpFS";
		//ret.rootNode.SetParent(mountPoint); TODO

		mountPoint.Mount(ret.rootNode);
		return ret;
	}

	override ulong Read(FileNode file, ulong offset, byte[] data) {
		if (file.GetAttributes().Length <= offset)
			return 0;

		ulong len = file.GetAttributes().Length - offset;
		if (len > data.length)
			len = data.length;

		data[] = (cast(TmpFileNode)file).data[offset .. offset + len];
		return len;
	}

	override ulong Write(FileNode file, ulong offset, byte[] data) {
		TmpFileNode node = cast(TmpFileNode)file;
		ulong end = offset + data.length;

		if (end > file.GetAttributes().Length) {
			byte[] tmp = new byte[end];

			if (node.data !is null) {
				tmp[] = node.data[0 .. $];
				delete node.data;
			}

			node.data = tmp;
		}

		node.data[offset .. end] = data[0 .. $];
		return data.length;
	}

	override FSNode Create(DirectoryNode parent, FileType type, FileAttributes fileAttributes) {
		switch (type) {
			case FileType.Directory:
				auto ret = new DirectoryNode(this, fileAttributes);
				parent.AddNode(ret);
				return ret;
			
			case FileType.File:
				auto ret = new TmpFileNode(this, fileAttributes);
				parent.AddNode(ret);
				return ret;

			default:
				return null;
		}
	}

	override bool Remove(DirectoryNode parent, FSNode node) {
		if (node.Type == FileType.File) {
			TmpFileNode n = cast(TmpFileNode)node;
			if (n.data !is null)
				delete n.data;

			return true;
		} else if (node.Type == FileType.Directory) {
			if (!(cast(DirectoryNode)node).Childrens.Count)
				return true;
		}

		return false;
	}
}