module VFSManager.FSNode;

import SyscallManager.Res;
import SyscallManager.Resource;
import VFSManager.FileSystemProto;
import VFSManager.DirectoryNode;

import System.IFace;
import System.String;
import System.DateTime;
import System.IO.FileAttributes;


abstract class FSNode : Resource {
package:
	FileSystemProto fs;
	DirectoryNode parent;
	FileAttributes attribs;


	this() {
		const CallTable[] callTable = [
			{IFace.FSNode.READ,      &SC_Read},
			{IFace.FSNode.WRITE,     &SC_Write},
			{IFace.FSNode.SETCWD,    &SC_SetCWD},
			{IFace.FSNode.REMOVE,    &SC_Remove},
			{IFace.FSNode.GETPATH,   &SC_GetPath},

			{IFace.FSNode.RSTATS,    &SC_ReadStats},
		];

		super(IFace.FSNode.OBJECT, callTable);
	}


public:
	@property FileType Type() { return attribs.Type; }
	@property FileSystemProto FileSystem() { return fs; }
	@property DirectoryNode Parent() { return parent; }
	@property void Parent(DirectoryNode parent) { this.parent = parent; } //TODO
	
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
	public static ulong SCall(ulong[] params) {
		import VFSManager.VFS; //TODO: FIXME
		import TaskManager.Task; //TODO: METOO
		import Devices.TTY; //TODO FIX ME PLZ
		import FileSystem.PipeDev; //SHIT HAPPENS

		if (params is null || !params.length)
			return ~0UL;

		final switch (params[0]) {
			case IFace.FSNode.SFIND:
				FSNode ret = VFS.Find(*cast(string *)params[1], params.length >= 3 ? cast(DirectoryNode)Res.GetByID(params[2], IFace.FSNode.OBJECT) : null);
				return ret is null ? 0 : ret.ResID();

			case IFace.FSNode.SMKDIR:
				DirectoryNode ret = VFS.CreateDirectory(*cast(string *)params[1], params.length >= 3 ? cast(DirectoryNode)Res.GetByID(params[2], IFace.FSNode.OBJECT) : null);
				return ret is null ? 0 : ret.ResID();

			case IFace.FSNode.SMKFILE:
				FSNode ret = VFS.CreateFile(*cast(string *)params[1], params.length >= 3 ? cast(DirectoryNode)Res.GetByID(params[2], IFace.FSNode.OBJECT) : null);
				return ret is null ? 0 : ret.ResID();

			case IFace.FSNode.SMKPIPE:
				/*if (params.length > 1) {
					string s = (*cast(string *)params[1]);
					string name = s[String.LastIndexOf(s, '/') + 1 .. $];
					string path = s[0 .. String.LastIndexOf(s, '/')];

					auto dir = VFS.Find(path);
					if (dir is null)
						return 0;

					auto ret = new PipeDev(0x2000, name);
					(cast(DirectoryNode)dir).AddNode(ret);
					return ret.ResID();
				}

				return (new PipeDev(0x2000)).ResID();*/
				break;
			case IFace.FSNode.CREATETTY:
				/*if (params.length < 3)
					return ~0UL;

				PTYDev master;
				TTYDev slave;
				new TTY(master, slave);
				*cast(ulong *)params[1] = master.ResID();
				*cast(ulong *)params[2] = slave.ResID();
				return 0;*/
				break;
			case IFace.FSNode.SGETRFN:
				return VFS.RootNode.ResID();

			case IFace.FSNode.SGETCWD:
				return Task.CurrentProcess.GetCWD().ResID();
		}

		return ~0UL;
	}

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

	ulong SC_WriteStats(ulong[] params) {
		return 0;
	}

	ulong SC_ReadStats(ulong[] params) {
		if (params is null || params.length < 1)
			return 0;

		//auto stats   = cast(FileStream.Stat *)params[0];
	/*	stats.type   = Type;
		stats.length = Length;
		stats.uid    = UID;
		stats.gid    = GID;
		stats.ctime  = CreateTime.Ticks;
		stats.mtime  = ModifyTime.Ticks;
		stats.atime  = AccessTime.Ticks;*/

		return 1;
	}
}