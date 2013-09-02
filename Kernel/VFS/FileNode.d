module VFS.FileNode;

import VFS.FSNode;
import VFS.DirectoryNode;
import VFS.FileSystemProto;


class FileNode : FSNode {
	this(string name, FileSystemProto fs, ulong length, uint perms = 0b111111111, ulong uid = 0, ulong gid = 0, ulong atime = 0, ulong mtime = 0, ulong ctime = 0) {
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

	long Read(ulong start, out byte[] data) {
		return fs.Read(this, start, data);
	}

	long Write(ulong start, in byte[] data) {
		return fs.Write(this, start, data);
	}
}