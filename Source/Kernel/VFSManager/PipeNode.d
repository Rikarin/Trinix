module VFSManager.PipeNode;

import VFSManager;


public abstract class PipeNode : FSNode {
	public this(DirectoryNode parent, FileAttributes attributes) {
		_attributes = attributes;
		_attributes.Type = FileType.Pipe;
		
		super(parent);
	}
}