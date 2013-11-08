module VFSManager.PipeNode;

import VFSManager.FSNode;
import VFSManager.DirectoryNode;
import System.IO.FileAttributes;


abstract class PipeNode : FSNode {
	this(FileAttributes fileAttributes) {
		attribs      = fileAttributes;
		attribs.Type = FileType.Pipe;
		super();
	}
}