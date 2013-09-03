module VFS.FileSystemProto;

import VFS.FSNode;
import VFS.DirectoryNode;
import VFS.FileNode;
import VFS.Partition;


abstract class FileSystemProto {
	private string identifier;

protected:
	bool isWritable;
	DirectoryNode rootNode;
	bool Unmount();


public:
	 bool IsWritable() { return isWritable; }
	 DirectoryNode RootNode() { return rootNode; }

	bool SetName(FSNode node, string name);
	bool SetPermissions(FSNode node, uint perms);
	bool SetUID(FSNode node, ulong uid);
	bool SetGID(FSNode node, ulong gid);
	bool SetParent(FSNode node, DirectoryNode parent);

	bool SetCreatedTime(FSNode node, ulong time);
	bool SetModifiedTime(FSNode node, ulong time);
	bool SetAccessedTime(FSNode node, ulong time);

	long Read(FileNode file, ulong start, byte[] data);
	long Write(FileNode file, ulong start, byte[] data);

	bool LoadContent(DirectoryNode dir);
	FileNode CreateFile(DirectoryNode parent, string name);
	DirectoryNode CreateDirectory(DirectoryNode parent, string name);
	bool Remove(DirectoryNode parent, FSNode node);

	Partition GetPartition();
	@property string Identifier() { return identifier; }
	@property void Identifier(string value) { identifier = value; }
}