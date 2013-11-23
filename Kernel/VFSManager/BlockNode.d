module VFSManager.BlockNode;

import VFSManager;
import System.IO;


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