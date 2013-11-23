module VFSManager.FSNode;

import VFSManager;
import SyscallManager;

import System;
import System.IO;
import System.IFace;


abstract class FSNode : Resource {
package:
	FileSystemProto fs;
	DirectoryNode parent;
	FileAttributes attribs;


	this() {
		const CallTable[] callTable = [
			{IFace.FSNode.READ,        &SC_Read},
			{IFace.FSNode.WRITE,       &SC_Write},
			{IFace.FSNode.SETCWD,      &SC_SetCWD},
			{IFace.FSNode.REMOVE,      &SC_Remove},
			{IFace.FSNode.GETPATH,     &SC_GetPath},
			{IFace.FSNode.WATTRIBUTES, &SC_ReadAttributes},
			{IFace.FSNode.RATTRIBUTES, &SC_ReadAttributes},
		];

		super(IFace.FSNode.OBJECT, callTable);
	}


public:
	@property FileType Type() { return attribs.Type; }
	@property FileSystemProto FileSystem() { return fs; }
	@property DirectoryNode Parent() { return parent; }
	
	ulong Read(ulong offset, byte[] data);
	ulong Write(ulong offset, byte[] data);
	FileAttributes GetAttributes() { return attribs; }
	
	void SetAttributes(FileAttributes fileAttributes) {
		if (fs is null)
			attribs = fileAttributes;
		else
			fs.SetAttributes(this, fileAttributes);
	}

	static FileAttributes NewAttributes(string name) {
		FileAttributes fa;
		fa.Name        = name;
		fa.AccessTime  = fa.CreateTime = fa.ModifyTime = DateTime.Now;
		fa.Permissions = 644;
		fa.UID         = 123;
		fa.GID         = 456;

		return fa;
	}


//TODO
private:
	ulong SC_Read(ulong[] params) {
		return Read(params[0], *(cast(byte[] *)params[1]));
	}

	ulong SC_Write(ulong[] params) {
		return Write(params[0], *(cast(byte[] *)params[1]));
	}

	ulong SC_SetCWD(ulong[]) {
		import TaskManager.Task; //TODO: FIXME
		
		if (GetAttributes().Type == FileType.Directory)
			Task.CurrentProcess.SetCWD(cast(DirectoryNode)this);

		return 0;
	}

	ulong SC_Remove(ulong[]) {
		import VFSManager.VFS; //TODO: FIXME
		return VFS.Remove(this) ? 1 : 0;
	}

	ulong SC_GetPath(ulong[] params) {
		import VFSManager.VFS; //TODO: FIXME

		string ret = VFS.Path(this);
		if (ret.length > params[1])
			return ~0UL;

		(cast(char *)params[0])[0 .. ret.length] = ret[0 .. $];
		return ret.length;
	}

	ulong SC_WriteAttributes(ulong[] params) {
		if (params is null || params.length < 1)
			return 0;

		*(cast(FileAttributes *)params[0]) = attribs;
		return 1;
	}

	ulong SC_ReadAttributes(ulong[] params) {
		if (params is null || params.length < 1)
			return 0;

		attribs = *(cast(FileAttributes *)params[0]);
		return 1;
	}
}