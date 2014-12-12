module FileSystem.TmpFS;

import VFSManager;


final class TmpFS : IFileSystem {
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
	
	bool Unmount() {
		return true;
	}
	
	private ulong Read(TmpFileNode node, long offset, byte[] data) {
		if (offset >= node.Attributes.Length)
			return 0;

		long length = node.Attributes.Length - offset;
		if (length > data.length)
			length = data.length;

		data[] = node._data[offset .. offset + length];
		return length;
	}
	
	private ulong Write(TmpFileNode node, long offset, byte[] data) {
		long end = offset + data.length;

		if (end > node.Attributes.Length) {
			byte[] tmp = new byte[end];

			if (node._data !is null) {
				tmp[0 .. node._data.length] = node._data[];
				delete node._data;
			}

			node._data = tmp;
		}

		node._data[offset .. end] = data[];
		return data.length;
	}
	
	bool LoadContent(DirectoryNode node) {
		return true;
	}
	
	FSNode Create(DirectoryNode parent, FileAttributes attributes) {
		switch (attributes.Type) {
			case FileType.Directory:
				return new DirectoryNode(parent, attributes);

			case FileType.File:
				return new TmpFileNode(parent, attributes);
				
			default:
				return null;
		}
	}
	
	bool Remove(FSNode node) {
		if (node.Attributes.Type == FileType.File) {
			auto n = cast(TmpFileNode)node;
			if (n._data !is null)
				delete n._data;
		}

		return true;
	}
	
	static TmpFS Mount(DirectoryNode mountpoint) {
		if (mountpoint is null || !mountpoint.IsMountpointable)
			return null;
		
		TmpFS ret = new TmpFS();
		ret._rootNode = new DirectoryNode(null, FSNode.NewAttributes("/"));
		ret._rootNode.FileSystem = ret;
		
		if (!mountpoint.Mount(ret._rootNode)) {
			delete ret;
			return null;
		}
		
		return ret;
	}
}


final class TmpFileNode : FileNode {
	private byte[] _data;
	
	
	@property override FileAttributes Attributes() {
		_attributes.Length = _data.length;
		return _attributes;
	}
	
	this(DirectoryNode parent, FileAttributes fileAttributes) {
		super(parent, fileAttributes);
	}

	~this() {
		delete _data;
	}

	override ulong Read(long offset, byte[] data) {
		if (_parent is null || _parent.FileSystem is null)
			return 0;
		
		return (cast(TmpFS)_parent.FileSystem).Read(this, offset, data);
	}
	
	override ulong Write(long offset, byte[] data) {
		if (_parent is null || _parent.FileSystem is null)
			return 0;
		
		return (cast(TmpFS)_parent.FileSystem).Write(this, offset, data);
	}
}