module VFS.FSNode;

import SyscallManager.Resource;
import VFS.FileSystemProto;
import VFS.DirectoryNode;
import System.IFace;


enum FSType : ubyte {
	FILE        = 0x01,
	DIRECTORY   = 0x02,
	CHARDEVICE  = 0x04,
	BLOCKDEVICE = 0x08,
	PIPE        = 0x10,
	SYMLINK     = 0x20,
	MOUNTPOINT  = 0x40,
	APPLICATION = 0x80
}

abstract class FSNode : Resource {
package:
	string name;
	FileSystemProto fs;
	DirectoryNode parent;

	ulong length;
	uint perms; //User/Group/Other -> RWX RWX RWX
	ulong uid, gid;

	ulong atime, mtime, ctime;


public:
	@property FSType Type();
	bool Removable() { return true; } //if we can remove node from directory tree
	//@property bool Used() { return false; }

	this() {
		const CallTable[] callTable = [
			{0, null}
		/*	{FNIF_GETNAME,   &GetNameSC},
			{FNIF_TYPE,      &TypeSC},
			{FNIF_GETPARENT, &GetParentSC},
			{FNIF_GETLENGTH, &GetLengthSC},
			{FNIF_GETUID,    &GetUidSC},
			{FNIF_GETGID,    &GetGidSC},
			{FNIF_GETPERM,   &GetParentSC},
			{FNIF_GETPATH,   &GetPathSC},
			{FNIF_SETCWD,    &SetCwdSC},
			{FNIF_REMOVE,    &RemovableSC}*/
		];

		super(FNIF_OBJTYPE, callTable);
	}

	@property string Name() { return name; }
	@property ulong Length() { return length; }
	@property uint Permissions() { return perms; }
	@property ulong UID() { return uid; }
	@property ulong GID() { return gid; }
	@property FileSystemProto FileSystem() { return fs; }
	@property DirectoryNode Parent() { return parent; }

	@property ulong CreatedTime() { return ctime; }
	@property ulong AccessedTime() { return atime; }
	@property ulong ModifiedTime() { return mtime; }

//	bool Readable() { return false; } //add User user = 0 TODO
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

	bool SetCreatedTime(ulong time) {
		bool ret = fs is null ? true : fs.SetCreatedTime(this, time);
		if (ret)
			ctime = time;

		return ret;
	}

	bool SetModifiedTime(ulong time) {
		bool ret = fs is null ? true : fs.SetModifiedTime(this, time);
		if (ret)
			mtime = time;

		return ret;
	}

	bool setAccessedTime(ulong time) {
		bool ret = fs is null ? true : fs.SetAccessedTime(this, time);
		if (ret)
			atime = time;

		return ret;
	}


private:
	public static ulong SCall(ulong[] params) {
		return 0;
	}

	/*ulong RemovableSC(ulong[]) { return Removable(); }
	ulong TypeSC(ulong[]) { return Type(); }

	ulong GetNameSC(ulong[]) {//TODO
		return 5;//name;
	}

	ulong GetLengthSC(ulong[]) {//TODO
		return 0;
	}

	ulong GetParentSC(ulong[]) {
		if (parent)
			return parent.ResID();
		return ~0UL;
	}

	ulong GetPathSC(ulong[]) {//TODO
		return 0;
	}

	ulong SetCwdSC(ulong[]) {//TODO
		return 0;
	}

	ulong RemoveSC(ulong[]) {//TODO
		return 0;
	}

	ulong GetUidSC(ulong[]) {//TODO
		return UID;
	}

	ulong GetGidSC(ulong[]) {//TODO
		return GID;
	}*/
}