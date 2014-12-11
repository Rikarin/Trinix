module FileSystem.DevFS;

import VFSManager;


public final class DevFS : IFileSystem {
	private DirectoryNode _rootNode;

	private this() {

	}
	
	@property Partition GetPartition() {
		return null;
	}

	@property bool IsWritable() {
		return true;
	}

	@property DirectoryNode RootNode() {
		return _rootNode;
	}
	
	public bool Unmount() {
		return true;
	}
	
	public bool LoadContent(DirectoryNode node) {
		return true;
	}

	public FSNode Create(DirectoryNode parent, FileAttributes attributes) {
		switch (attributes.Type) {
			case FileType.Directory:
				return new DirectoryNode(parent, attributes);

			default:
				return null;
		}
	}

	public bool Remove(FSNode node) {
		switch (node.Attributes.Type) {
			case FileType.Directory:
				if (!(cast(DirectoryNode)node).Childrens.Count) {
					delete node;
					return true;
				}
				break;

			default:
				delete node;
				return true;
		}

		return false;
	}

	public static DevFS Mount(DirectoryNode mountpoint) {
		if (mountpoint is null || !mountpoint.IsMountpointable)
			return null;

		DevFS ret = new DevFS();
		ret._rootNode = new DirectoryNode(null, FSNode.NewAttributes("/"));
		ret._rootNode.FileSystem = ret;

		if (!mountpoint.Mount(ret._rootNode)) {
			delete ret;
			return null;
		}

		return ret;
	}

	public bool AddDevice(FSNode dev) {
		return false;
	}
}