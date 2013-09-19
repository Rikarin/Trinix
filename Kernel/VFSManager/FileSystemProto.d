module VFSManager.FileSystemProto;

import VFSManager.FSNode;
import VFSManager.DirectoryNode;
import VFSManager.FileNode;
import VFSManager.Partition;
import System.DateTime;


abstract class FileSystemProto {
	private string identifier;

public:
	bool isWritable;
	DirectoryNode rootNode;
	bool Unmount();

	bool IsWritable() { return isWritable; }
	DirectoryNode RootNode() { return rootNode; }

	bool SetName(FSNode node, string name);
	bool SetPermissions(FSNode node, uint perms);
	bool SetUID(FSNode node, ulong uid);
	bool SetGID(FSNode node, ulong gid);
	bool SetParent(FSNode node, DirectoryNode parent);

	bool SetCreatedTime(FSNode node, DateTime time);
	bool SetModifiedTime(FSNode node, DateTime time);
	bool SetAccessedTime(FSNode node, DateTime time);

	ulong Read(FileNode file, ulong offset, byte[] data);
	ulong Write(FileNode file, ulong offset, byte[] data);

	bool LoadContent(DirectoryNode dir);
	FileNode CreateFile(DirectoryNode parent, string name);
	DirectoryNode CreateDirectory(DirectoryNode parent, string name);
	bool Remove(DirectoryNode parent, FSNode node);

	Partition GetPartition();
	@property string Identifier() { return identifier; }
	@property void Identifier(string value) { identifier = value; }
}