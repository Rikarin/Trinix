module VFSManager.FileNode;

import VFSManager;


abstract class FileNode : FSNode {
	this(DirectoryNode parent, FileAttributes fileAttributes) {
		_attributes      = fileAttributes;
		_attributes.Type = FileType.File;

		super(parent);
	}
}