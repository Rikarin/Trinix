module VFSManager.IFileSystem;

import VFSManager;


public interface IFileSystem {
	@property Partition GetPartition(); 
	@property bool IsWritable();
	@property DirectoryNode RootNode();

	public bool Unmount();

	public bool LoadContent(DirectoryNode node);
	public FSNode Create(DirectoryNode parent, FileAttributes attributes);
	public bool Remove(FSNode node);
}