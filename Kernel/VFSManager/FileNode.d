module VFSManager.FileNode;

import VFSManager.FSNode;
import VFSManager.DirectoryNode;
import VFSManager.FileSystemProto;
import System.DateTime;


class FileNode : FSNode {
	this(string name, FileSystemProto fs, ulong length, uint perms = 0b110100100, ulong uid = 0, ulong gid = 0, DateTime atime = null, DateTime mtime = null, DateTime ctime = null) {
		super();

		this.name   = name;
		this.fs     = fs;
		this.length = length;
		this.perms  = perms;
		this.uid    = uid;
		this.gid    = gid;
		this.atime  = atime;
		this.ctime  = ctime;
		this.mtime  = mtime;
	}

	
	@property override FSType Type() { return FSType.FILE; }
	//@property override bool Used() { return readers || writers; }
	//bool IsWritableFS() { return fs.IsWritable(); }

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

	//Syscalls
	override bool Accessible() { return true; }
}