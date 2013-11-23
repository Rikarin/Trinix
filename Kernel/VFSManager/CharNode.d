module VFSManager.CharNode;

import VFSManager;
import System.IO;


abstract class CharNode : FSNode {
	this(FileAttributes fileAttributes) {
		attribs = fileAttributes;
		attribs.Type = FileType.CharDevice;
		super();
	}
}