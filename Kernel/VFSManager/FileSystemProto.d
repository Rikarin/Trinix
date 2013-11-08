module VFSManager.FileSystemProto;

import VFSManager.FSNode;
import VFSManager.DirectoryNode;
import VFSManager.FileNode;
import VFSManager.Partition;

import System.DateTime;
import System.IO.FileAttributes;


abstract class FileSystemProto {
protected:
	string identifier;
	bool isWritable;
	DirectoryNode rootNode;
	Partition part;


public:
	@property string Identifier() { return identifier; }
	@property void Identifier(string value) { identifier = value; }
	@property Partition GetPartition() { return part; }
	@property bool IsWritable() { return isWritable; }
	@property DirectoryNode RootNode() { return rootNode; }

	bool Unmount();
	FileAttributes GetAttributes(FSNode node);
	void SetAttributes(FSNode node, FileAttributes fileAttributes);

	ulong Read(FileNode file, ulong offset, byte[] data);
	ulong Write(FileNode file, ulong offset, byte[] data);

	bool LoadContent(DirectoryNode dir);
	FSNode Create(DirectoryNode parent, FileType type, FileAttributes fileAttributes);
	bool Remove(DirectoryNode parent, FSNode node);
}