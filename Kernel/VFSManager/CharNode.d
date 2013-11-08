module VFSManager.CharNode;

import VFSManager.FSNode;
import VFSManager.DirectoryNode;
import System.IO.FileAttributes;


abstract class CharNode : FSNode {
	this(FileAttributes fileAttributes) {
		attribs = fileAttributes;
		attribs.Type = FileType.CharDevice;
		super();
	}
}