module VFSManager.CharNode;

import VFSManager;


public abstract class CharNode : FSNode {
	public this(DirectoryNode parent, FileAttributes attributes) {
		_attributes = attributes;
		_attributes.Type = FileType.CharDevice;

		super(parent);
	}
}