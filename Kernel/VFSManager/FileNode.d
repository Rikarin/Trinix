module VFSManager.FileNode;

import VFSManager.FSNode;
import VFSManager.DirectoryNode;
import VFSManager.FileSystemProto;
import System.DateTime;
import System.IO.FileAttributes;


class FileNode : FSNode {
	this(FileSystemProto fileSystem, FileAttributes fileAttributes) {
		attribs      = fileAttributes;
		fs           = fileSystem;
		attribs.Type = FileType.File;
		super();
	}

	override ulong Read(ulong offset, byte[] data) {
		if (fs is null)
			return 0;

		return fs.Read(this, offset, data);
	}

	override ulong Write(ulong offset, byte[] data) {
		if (fs is null)
			return 0;
		
		return fs.Write(this, offset, data);
	}
}