module VFSManager.BlockNode;

import VFSManager;


abstract class BlockNode : FSNode {
	@property long Blocks();
	@property long BlockSize();

	this(DirectoryNode parent, FileAttributes attributes) {
		_attributes = attributes;
		_attributes.Type = FileType.BlockDevice;

		super(parent);
	}
}