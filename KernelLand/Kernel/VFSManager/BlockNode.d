module VFSManager.BlockNode;

import VFSManager;


public abstract class BlockNode : FSNode {
	@property long Blocks();
	@property long BlockSize();

	public this(DirectoryNode parent, FileAttributes attributes) {
		_attributes = attributes;
		_attributes.Type = FileType.BlockDevice;

		super(parent);
	}
}