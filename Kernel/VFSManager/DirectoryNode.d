module VFSManager.DirectoryNode;

import System.Collections.Generic.All;
import VFSManager.FileSystemProto;
import VFSManager.FSNode;
import VFSManager.FileNode;
import System.IFace;
import System.DateTime;


class DirectoryNode : FSNode {
package:
	public List!(FSNode) childrens;
	bool isLoaded = false;
	DirectoryNode mounts = null;


public:
	@property override FSType Type() { return mounts ? FSType.MOUNTPOINT : FSType.DIRECTORY; }
	void Unmount() { mounts = null; }
	override long Read(ulong offset, byte[] data) { return 0; }
	override long Write(ulong offset, byte[] data) { return 0; }


	@property override string Name() {
		if (name == "/" && parent)
			return parent.Name;
		return name;
	}

	@property override ulong Length() {
		if (mounts)
			return mounts.Length;

		if (!LoadContent())
			return 0;

		return length;
	}

	@property override DirectoryNode Parent() {
		if (name == "/" && parent)
			return parent.Parent;

		return parent;
	}

	@property List!(FSNode) Childrens() {
		if (mounts)
			mounts.Childrens;

		if (!isLoaded)
			LoadContent();

		return childrens;
	}

	this(string name, FileSystemProto fs, uint perms = 0b110100100, ulong uid = 0, ulong gid = 0, DateTime atime = null, DateTime mtime = null, DateTime ctime = null) {
		/*const CallTable[] callTable = [
			{FNIF_GETIDXCHILD, &GetIdxChildSC},
			{FNIF_GETNAME, &GetNameChildSC}
		];*/
		//AddCallTable(callTable);

		childrens   = new List!(FSNode)();
		this.name   = name;
		this.fs     = fs;
		this.perms  = perms;
		this.uid    = uid;
		this.gid    = gid;
		this.atime  = atime;
		this.ctime  = ctime;
		this.mtime  = mtime;
		super();
	}

	~this() {
		if (name == "/" && parent)
			(cast(DirectoryNode)parent).Unmount();

		delete childrens;
	}

	bool Mount(DirectoryNode childRoot) {
		if (Mountpointable()) {
			mounts = childRoot;
			return true;
		}
		return false;
	}

	bool LoadContent() {
		if (mounts)
			return mounts.LoadContent();

		if(isLoaded || fs is null)
			return true;

		bool ret = fs.LoadContent(this);
		if (!ret)
			return false;
		
		length = childrens.Count;
		isLoaded = true;
		return ret;
	}

	override bool Removable() {
		if (!LoadContent())
			return false;

		return !childrens.Count && mounts is null;
	}

	bool Mountpointable() {
		if (!LoadContent())
			return false;

		return !childrens.Count;
	}

	FSNode GetChild(ulong index) {
		if (mounts)
			return mounts.GetChild(index);

		if (!LoadContent())
			return null;

		if (index >= childrens.Count)
			return null;

		return childrens[index];
	}

	FSNode GetChild(string name) {
		if (mounts)
			return mounts.GetChild(name);

		if (!LoadContent())
			return null;

		foreach (x; childrens) {
			if (x.Name == name)
				return x;
		}

		return null;
	}

	DirectoryNode CreateDirectory(string name) {
		if (mounts)
			mounts.CreateDirectory(name);

		DirectoryNode ret;
		if (fs !is null)
			ret = fs.CreateDirectory(this, name);
		else {
			ret = new DirectoryNode(name, null);
			AddNode(ret);
		}
		
		return ret;
	}

	FileNode CreateFile(string name) {
		if (mounts)
			mounts.CreateFile(name);

		FileNode ret;
		if (fs !is null)
			ret = fs.CreateFile(this, name);
		else
			ret = null;

		return ret;
	}

	bool Remove(FSNode child) {
		if (mounts)
			return mounts.Remove(child);

		if (!LoadContent())
			return false;

		foreach (x; childrens) {
			if (x == child) {
				if (!x.Removable())
					return false;

				if (fs != x.FileSystem)
					return false;

				if (!fs.Remove(this, child))
					return false;

				childrens.Remove(x);
				length--;
				return true;
			}
		}

		return false;
	}

	void AddNode(FSNode node) {
		childrens.Add(node);
		node.parent = this;
		length++;
	}


	//Syscalls
	override bool Accesible() { return true; }
/*private:
	ulong GetIdxChildSC(ulong[] params) {
		if (!Runnable())
			return ~0UL;

		FSNode n = GetChild(params[0]);
		if (n)
			return n.ResID();
		return ~0UL;
	}

	ulong GetNameChildSC(ulong[] params) { //TODO 
		return 0;
	}*/
}