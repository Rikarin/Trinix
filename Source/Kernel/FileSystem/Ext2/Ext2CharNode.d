module FileSystem.Ext2.Ext2CharNode;

import VFSManager;
import FileSystem.Ext2;


public final class Ext2CharNode : CharNode {
	private Ext2Filesystem.Inode _inode;
	private bool _loadedAttribs;
	
	public this(int inode, DirectoryNode parent, FileAttributes attributes) {
		if (parent !is null && parent.FileSystem !is null)
			(cast(Ext2Filesystem)parent.FileSystem).ReadInode(_inode, inode);
		
		super(parent, attributes);
	}
	
	@property public override FileAttributes Attributes() {
		if (!_loadedAttribs && _parent !is null && _parent.FileSystem !is null) {
			auto atribs = (cast(Ext2Filesystem)_parent.FileSystem).GetAttributes(_inode);
			atribs.Name = _attributes.Name;
			_attributes = atribs;
			_loadedAttribs = true;
		}
		
		return _attributes;
	}
	
	@property public override void Attributes(FileAttributes value) {
		_attributes = value; //TODO
	}
	
	public override ulong Read(long offset, byte[] data) {
		if (_parent is null || _parent.FileSystem is null)
			return 0;
		
		return (cast(Ext2Filesystem)_parent.FileSystem).Read(_inode, offset, data);
	}
	
	public override ulong Write(long offset, byte[] data) {
		if (_parent is null || _parent.FileSystem is null)
			return 0;
		
		return (cast(Ext2Filesystem)_parent.FileSystem).Write(_inode, offset, data);
	}
}