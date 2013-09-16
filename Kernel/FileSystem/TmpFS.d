module FileSystem.TmpFS;

import VFSManager.FileSystemProto;
import VFSManager.DirectoryNode;
import VFSManager.FSNode;
import System.DateTime;
import VFSManager.FileNode;
import VFSManager.Partition;


class TmpFileNode : FileNode {
	private byte[] data;
	package void SetLength(ulong length) { this.length = length; }

	this(string name, FileSystemProto fs, ulong length = 0, uint perms = 0b110100100, ulong uid = 0, ulong gid = 0) {
		DateTime now = DateTime.Now;
		super(name, fs, length, perms, uid, gid, now, now, now);
	}

	~this() { delete data; }
}


class TmpFS : FileSystemProto {
	this() { }

	static TmpFS Mount(DirectoryNode mountPoint) {
		if (mountPoint && !mountPoint.Mountpointable())
			return null;

		TmpFS ret = new TmpFS();
		ret.isWritable = true;
		ret.rootNode = new DirectoryNode("/", ret);
		ret.Identifier = "TmpFS";
		ret.rootNode.SetParent(mountPoint);

		mountPoint.Mount(ret.rootNode);
		return ret;
	}


	override bool Unmount() { return true; }

	override bool SetName(FSNode node, string name) { return true; }
	override bool SetPermissions(FSNode node, uint perms) { return true; }
	override bool SetUID(FSNode node, ulong uid) { return true; }
	override bool SetGID(FSNode node, ulong gid) { return true; }
	override bool SetParent(FSNode node, DirectoryNode parent) { return true; }

	override bool SetCreatedTime(FSNode node, DateTime time) { return true; }
	override bool SetModifiedTime(FSNode node, DateTime time) { return true; }
	override bool SetAccessedTime(FSNode node, DateTime time) { return true; }
	
	override bool LoadContent(DirectoryNode dir) { return true; }
	override Partition GetPartition() { return null; }

	override long Read(FileNode file, ulong offset, byte[] data) {
		if (file.Length <= offset)
			return 0;

		ulong len = file.Length - offset;
		if (len > data.length)
			len = data.length;

		data[] = (cast(TmpFileNode)file).data[offset .. offset + len];
		return len;
	}

	override long Write(FileNode file, ulong offset, byte[] data) {
		TmpFileNode node = cast(TmpFileNode)file;
		ulong end = offset + data.length;

		if (end > file.Length) {
			byte[] tmp = new byte[end];

			if (node.data !is null) {
				tmp[] = node.data[0 .. $];
				delete node.data;
			}

			node.data = tmp;
			node.SetLength(node.data.length);
		}

		node.data[offset .. end] = data[0 .. $];
		return data.length;
	}

	override FileNode CreateFile(DirectoryNode parent, string name) {
		TmpFileNode ret = new TmpFileNode(name, this);
		parent.AddNode(ret);
		return ret;
	}

	override DirectoryNode CreateDirectory(DirectoryNode parent, string name) {
		DirectoryNode ret = new DirectoryNode(name, this);
		parent.AddNode(ret);
		return ret;
	}

	override bool Remove(DirectoryNode parent, FSNode node) {
		if (node.Type == FSType.FILE) {
			TmpFileNode n = cast(TmpFileNode)node;
			if (n.data !is null)
				delete n.data;

			return true;
		} else if (node.Type == FSType.DIRECTORY) {
			if (!(cast(DirectoryNode)node).Childrens.Count)
				return true;
		}

		return false;
	}
}