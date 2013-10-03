module VFSManager.FSNode;

import SyscallManager.Resource;
import VFSManager.FileSystemProto;
import VFSManager.DirectoryNode;
//import VFSManager.VFS;// WTF?
import System.IFace;
import System.DateTime;
//import TaskManager.Task; //WTF?


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
			{IFace.FSNode.TYPE,      &SC_Type},
			{IFace.FSNode.READ,      &SC_Read},
			{IFace.FSNode.WRITE,     &SC_Write},
			{IFace.FSNode.GETUID,    &SC_GetUID},
			{IFace.FSNode.GETGID,    &SC_GetGID},
			{IFace.FSNode.SETCWD,    &SC_SetCWD},
			//{IFace.FSNode.REMOVE,    &SC_Remove}
			//{IFace.FSNode.GETNAME,   &SC_GetName},
			{IFace.FSNode.GETPERM,   &SC_GetPerm},
			{IFace.FSNode.SETPERM,   &SC_SetPerm},
			//{FNIF_GETPATH,           &GetPathSC},
			{IFace.FSNode.GETATIME,  &SC_GetAccessTime},
			{IFace.FSNode.GETMTIME,  &SC_GetModifyTime},
			{IFace.FSNode.GETCTIME,  &SC_GetCreateTime},
			{IFace.FSNode.SETATIME,  &SC_SetAccessTime},
			{IFace.FSNode.SETMTIME,  &SC_SetModifyTime},
			{IFace.FSNode.SETCTIME,  &SC_SetCreateTime},
			{IFace.FSNode.REMOVABLE, &SC_Removable},
			{IFace.FSNode.GETLENGTH, &SC_GetLength},
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
		if (params is null || params.length < 2)
			return ~1UL;

		switch (params[0]) {
			case IFace.FSNode.SFIND:
				//return VFS.Find(params[1], params.length >= 3 ? params[2] : null);
				break;
			case IFace.FSNode.SMKDIR:
				//return VFS.CreatDirectory(params[1], params.length >= 3 ? params[2] : null);
				break;
			case IFace.FSNode.SGETRFN:
				//return VFS.RootNode.ResID();
			case IFace.FSNode.SGETCWD:
				//return Task.CurrentProcess.GetCWD().ResID();
			default:
				return ~1UL;
		}

		return ~1UL;
	}

	ulong SC_Type(ulong[]) {
		return Type;
	}

	ulong SC_Read(ulong[] params) {
		return Read(params[0], *(cast(byte[] *)params[1]));
	}

	ulong SC_Write(ulong[] params) {
		return Write(params[0], *(cast(byte[] *)params[1]));
	}

	ulong SC_GetUID(ulong[]) {
		return uid;
	}

	ulong SC_GetGID(ulong[]) {
		return gid;
	}

	ulong SC_SetCWD(ulong[]) {
		//if (Type == FSType.DIRECTORY)
		//	Task.CurrentProcess.SetCWD(cast(DirectoryNode)this);

		return 0;
	}

	/*ulong SC_Remove(ulong[]) {//TODO
		return 0;
	}*/

	/*ulong SC_GetName(ulong[]) {//TODO
		return 5;//name;
	}*/

	ulong SC_GetPerm(ulong[]) {
			return perms;
	}

	ulong SC_SetPerm(ulong[] params) {
		if (!params.length)
			return 0;

		return SetPermissions(cast(uint)params[0]);
	}

	/*ulong SC_GetPath(ulong[]) {//TODO
		return 0;
	}*/

	ulong SC_GetAccessTime(ulong[]) {
		return atime.Ticks;
	}

	ulong SC_GetModifyTime(ulong[]) {
		return mtime.Ticks;
	}

	ulong SC_GetCreateTime(ulong[]) {
		return ctime.Ticks;
	}

	ulong SC_SetAccessTime(ulong[] params) {
		if (!params.length)
			return 0;

		return SetAccessTime(new DateTime(params[0]));
	}

	ulong SC_SetModifyTime(ulong[] params) {
		if (!params.length)
			return 0;

		return SetModifyTime(new DateTime(params[0]));
	}

	ulong SC_SetCreateTime(ulong[] params) {
		if (!params.length)
			return 0;

		return SetCreateTime(new DateTime(params[0]));
	}

	ulong SC_Removable(ulong[]) {
		return Removable();
	}

	ulong SC_GetLength(ulong[]) {
		return length;
	}
}