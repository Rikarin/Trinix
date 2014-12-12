module VFSManager.CharNode;

import VFSManager;


abstract class CharNode : FSNode {
	this(DirectoryNode parent, FileAttributes attributes) {
		_attributes = attributes;
		_attributes.Type = FileType.CharDevice;

		super(parent);
	}
}