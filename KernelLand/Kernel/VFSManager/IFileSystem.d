module VFSManager.IFileSystem;

import VFSManager;


public interface IFileSystem {
	@property Partition GetPartition(); 
	@property bool IsWritable();
	@property DirectoryNode RootNode();

	public bool Unmount();

	public FSNode Find(DirectoryNode node, ulong num);
	public FSNode Create(DirectoryNode parent, FileAttributes attributes);
	public bool Remove(FSNode node);
}