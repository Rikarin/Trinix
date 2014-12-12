module VFSManager.IFileSystem;

import VFSManager;


interface IFileSystem {
	@property Partition GetPartition(); 
	@property bool IsWritable();
	@property DirectoryNode RootNode();

	bool Unmount();

	bool LoadContent(DirectoryNode node);
	FSNode Create(DirectoryNode parent, FileAttributes attributes);
	bool Remove(FSNode node);
}