module VFS.DirectoryNode;

import System.Collections.Generic.All;
import VFS.FileSystemProto;
import VFS.FSNode;
import System.IFace;


class DirectoryNode : FSNode {
protected:
	List!(FSNode) childrens;
	bool isLoaded;
	DirectoryNode mounts;


public:
	@property override FSType Type() { return mounts ? FSType.MOUNTPOINT : FSType.DIRECTORY; }
/*	@property ref List!(FSNode) Childrens() { return childrens; }
	void Mount(DirectoryNode childRoot) { mounts = childRoot; }
	void Unmount() { mounts = null; }


	this(string name, FileSystemProto fs, uint perms = 0b111111111, ulong uid = 0, ulong gid = 0) {
		/*const CallTable[] callTable = [
			{FNIF_GETIDXCHILD, &GetIdxChildSC},
			{FNIF_GETNAME, &GetNameChildSC}
		];*/

/*		super(name, fs, 0, perms, uid, gid);
		//AddCallTable(callTable);

		childrens = new List!(FSNode)();
		isLoaded = false;
		mounts = null;
	}

	~this() {
		//delete childrens; TODO
		
		if (name == "/" && parent)
			(cast(DirectoryNode)parent).Unmount();
	}

	bool LoadContent() {
		if (mounts)
			return mounts.LoadContent();

		if(isLoaded)
			return true;

		bool ret = fs.LoadContent(this);
		if (!ret)
			return false;
		
		length = childrens.Count;
		isLoaded = true;
		return ret;
	}
	
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

	@property override FSNode Parent() {
		if (name == "/" && parent)
			return parent.Parent;
		return parent;
	}

	@property override bool Removable() {
		if (!LoadContent())
			return false;
		return !childrens.Count && mounts is null;
	}

	bool Unmontable() {
		if (!isLoaded)
			return true;

		if (mounts)
			return false;

		foreach (x; childrens) {
			if (x.Type == FS_MOUNTPOINT) {
				if (!(cast(DirectoryNode)x).Unmontable())
					return false;
				else if (!x.Removable())
					return false;
			}
		}
		return true;
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

	List!(FSNode) GetChildrens() {
		if (mounts)
			mounts.GetChildrens();

		if (!isLoaded)
			LoadContent();

		return childrens;
	}

	DirectoryNode CreateDirectory(string name) {
		if (mounts)
			mounts.CreateDirectory(name);

		DirectoryNode ret = fs.CreateDirectory(this, name);
		length = childrens.Count;
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

	//TODO create file...

*/
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