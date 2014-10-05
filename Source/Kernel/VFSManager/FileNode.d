module VFSManager.FileNode;

import VFSManager;


public abstract class FileNode : FSNode {
	public this(DirectoryNode parent, FileAttributes fileAttributes) {
		_attributes      = fileAttributes;
		_attributes.Type = FileType.File;

		super(parent);
	}
}