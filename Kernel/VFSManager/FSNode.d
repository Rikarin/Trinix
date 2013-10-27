module VFSManager.FSNode;

import SyscallManager.Res;
import SyscallManager.Resource;
import VFSManager.FileSystemProto;
import VFSManager.DirectoryNode;
import System.IFace;
import System.DateTime;
import System.String;
import System.IO.FileStream;


enum FSType : ubyte {
	FILE        = 0x01,
	DIRECTORY   = 0x02,
	CHARDEVICE  = 0x04,
	BLOCKDEVICE = 0x08,
	PIPE        = 0x10,
	SYMLINK     = 0x20,
	MOUNTPOINT  = 0x40
}

abstract class FSNode : Resource {
package:
	string name;
	FileSystemProto fs;
	DirectoryNode parent;

	ulong length;
	/** User/Group/Other -> RWX RWX RWX */
	uint perms;
	ulong uid, gid;

	DateTime atime, mtime, ctime;


public:
	@property FSType Type();
	/** if we can remove node from directory tree */
	bool Removable() { return true; }
	
	ulong Read(ulong offset, byte[] data);
	ulong Write(ulong offset, byte[] data);

	this() {
		const CallTable[] callTable = [
			{IFace.FSNode.READ,      &SC_Read},
			{IFace.FSNode.WRITE,     &SC_Write},
			{IFace.FSNode.SETCWD,    &SC_SetCWD},
			{IFace.FSNode.REMOVE,    &SC_Remove},
			{IFace.FSNode.GETPATH,   &SC_GetPath},
			{IFace.FSNode.REMOVABLE, &SC_Removable},

			{IFace.FSNode.RSTATS,    &SC_ReadStats},
		];

		super(IFace.FSNode.OBJECT, callTable);
	}

	@property string Name() { return name; }
	@property ulong Length() { return length; }
	@property uint Permissions() { return perms; }
	@property ulong UID() { return uid; }
	@property ulong GID() { return gid; }
	@property FileSystemProto FileSystem() { return fs; }
	@property DirectoryNode Parent() { return parent; }

	@property DateTime CreateTime() { return ctime; }
	@property DateTime AccessTime() { return atime; }
	@property DateTime ModifyTime() { return mtime; }

	//bool Readable() { return false; } //add User user = 0 TODO
	//bool Writable() { return false; } //TODO
	//bool Runnable() { return false; } //TODO

	bool SetName(string name) {
		bool ret = fs is null ? true : fs.SetName(this, name);
		if (ret)
			this.name = name;

		return ret;
	}

	bool SetPermissions(uint perms) {
		bool ret = fs is null ? true : fs.SetPermissions(this, perms);
		if (ret)
			this.perms = perms;

		return ret;
	}

	bool SetUID(ulong uid) {
		bool ret = fs is null ? true : fs.SetUID(this, uid);
		if (ret)
			this.uid = uid;

		return ret;
	}

	bool SetGID(ulong gid) {
		bool ret = fs is null ? true : fs.SetGID(this, gid);
		if (ret)
			this.gid = gid;

		return ret;
	}

	bool SetParent(DirectoryNode parent) {
		bool ret = fs is null ? true : fs.SetParent(this, parent);
		if (ret)
			this.parent = parent;

		return ret;
	}

	bool SetCreateTime(DateTime time) {
		bool ret = fs is null ? true : fs.SetCreateTime(this, time);
		if (ret)
			ctime = time;

		return ret;
	}

	bool SetModifyTime(DateTime time) {
		bool ret = fs is null ? true : fs.SetModifyTime(this, time);
		if (ret)
			mtime = time;

		return ret;
	}

	bool SetAccessTime(DateTime time) {
		bool ret = fs is null ? true : fs.SetAccessTime(this, time);
		if (ret)
			atime = time;

		return ret;
	}


private:
	public static ulong SCall(ulong[] params) {
		import VFSManager.VFS; //TODO: FIXME
		import TaskManager.Task; //TODO: METOO
		import Devices.TTY; //TODO FIX ME PLZ
		import FileSystem.PipeDev; //SHIT HAPPENS

		if (params is null || !params.length)
			return ~0UL;

		switch (params[0]) {
			case IFace.FSNode.SFIND:
				FSNode ret = VFS.Find(*cast(string *)params[1], params.length >= 3 ? cast(DirectoryNode)Res.GetByID(params[2], IFace.FSNode.OBJECT) : null);
				return ret is null ? 0 : ret.ResID();
				break;
			case IFace.FSNode.SMKDIR:
				DirectoryNode ret = VFS.CreateDirectory(*cast(string *)params[1], params.length >= 3 ? cast(DirectoryNode)Res.GetByID(params[2], IFace.FSNode.OBJECT) : null);
				return ret is null ? 0 : ret.ResID();
				break;
			case IFace.FSNode.SMKFILE:
				FSNode ret = VFS.CreateFile(*cast(string *)params[1], params.length >= 3 ? cast(DirectoryNode)Res.GetByID(params[2], IFace.FSNode.OBJECT) : null);
				return ret is null ? 0 : ret.ResID();
				break;
			case IFace.FSNode.SMKPIPE:
				if (params.length > 1) {
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

				return (new PipeDev(0x2000)).ResID();
				break;
			case IFace.FSNode.CREATETTY:
				if (params.length < 3)
					return ~0UL;

				PTYDev master;
				TTYDev slave;
				new TTY(master, slave);
				*cast(ulong *)params[1] = master.ResID();
				*cast(ulong *)params[2] = slave.ResID();
				return 0;
				break;
			case IFace.FSNode.SGETRFN:
				return VFS.RootNode.ResID();
			case IFace.FSNode.SGETCWD:
				return Task.CurrentProcess.GetCWD().ResID();
			default:
				return ~0UL;
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
		
		if (Type == FSType.DIRECTORY)
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

	ulong SC_Removable(ulong[]) {
		return Removable();
	}

	ulong SC_WriteStats(ulong[] params) {
		return 0;
	}

	ulong SC_ReadStats(ulong[] params) {
		if (params is null || params.length < 1)
			return 0;

		auto stats   = cast(FileStream.Stat *)params[0];
		stats.type   = Type;
		stats.length = Length;
		stats.uid    = UID;
		stats.gid    = GID;
		stats.ctime  = CreateTime.Ticks;
		stats.mtime  = ModifyTime.Ticks;
		stats.atime  = AccessTime.Ticks;

		return 1;
	}
}