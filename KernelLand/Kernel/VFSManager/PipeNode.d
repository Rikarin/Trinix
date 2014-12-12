module VFSManager.PipeNode;

import VFSManager;


abstract class PipeNode : FSNode {
	this(DirectoryNode parent, FileAttributes attributes) {
		_attributes = attributes;
		_attributes.Type = FileType.Pipe;
		
		super(parent);
	}
}