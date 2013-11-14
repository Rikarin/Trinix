module VFSManager.BlockNode;

import VFSManager.FSNode;
import VFSManager.DirectoryNode;
import System.IO.FileAttributes;


abstract class BlockNode : FSNode {
	static __gshared char Letter = 'a';

	@property ulong Blocks() const;
	@property uint BlockSize() const;


	this(FileAttributes fileAttributes) {
		attribs = fileAttributes;
		attribs.Type = FileType.BlockDevice;
		super();
	}
}