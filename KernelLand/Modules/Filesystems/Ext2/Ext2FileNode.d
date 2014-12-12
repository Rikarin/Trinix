module Modules.Filesystems.Ext2.Ext2FileNode;

import VFSManager;
import Modules.Filesystems.Ext2.Ext2Filesystem;


final class Ext2FileNode : FileNode {
	private Ext2Filesystem.Inode _inode;
	private bool _loadedAttribs;
	
	this(int inode, DirectoryNode parent, FileAttributes attributes) {
		if (parent !is null && parent.FileSystem !is null)
			(cast(Ext2Filesystem)parent.FileSystem).ReadInode(_inode, inode);
		
		super(parent, attributes);
	}
	
	@property override FileAttributes Attributes() {
		if (!_loadedAttribs && _parent !is null && _parent.FileSystem !is null) {
			auto attribs = (cast(Ext2Filesystem)_parent.FileSystem).GetAttributes(_inode);
			attribs.Name = _attributes.Name;
			attribs.Type = _attributes.Type;

			_attributes = attribs;
			_loadedAttribs = true;
		}
		
		return _attributes;
	}
	
	@property override void Attributes(FileAttributes value) {
		_attributes = value; //TODO
	}
	
	override ulong Read(long offset, byte[] data) {
		if (_parent is null || _parent.FileSystem is null)
			return 0;
		
		return (cast(Ext2Filesystem)_parent.FileSystem).Read(_inode, offset, data);
	}
	
	override ulong Write(long offset, byte[] data) {
		if (_parent is null || _parent.FileSystem is null)
			return 0;
		
		return (cast(Ext2Filesystem)_parent.FileSystem).Write(_inode, offset, data);
	}
}