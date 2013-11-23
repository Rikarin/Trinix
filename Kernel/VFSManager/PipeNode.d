module VFSManager.PipeNode;

import VFSManager;
import System.IO;


abstract class PipeNode : FSNode {
	this(FileAttributes fileAttributes) {
		attribs      = fileAttributes;
		attribs.Type = FileType.Pipe;
		super();
	}
}