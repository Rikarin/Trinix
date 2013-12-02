module VFSManager.DirectoryNode;

import VFSManager;

import System;
import System.IO;
import System.IFace;
import System.Collections.Generic;


class DirectoryNode : FSNode {
package:
	List!FSNode childrens;
	bool isLoaded;
	DirectoryNode mounts;


public:
	@property bool IsLoaded() { return isLoaded; }
	@property void IsLoaded(bool value) { isLoaded = value; }
		
	override ulong Read(ulong offset, byte[] data) { return 0; }
	override ulong Write(ulong offset, byte[] data) { return 0; }

	
	override FileAttributes GetAttributes() {
		if (attribs.Name == "/" && parent)
			return parent.attribs;

		return attribs;
	}

	@property override DirectoryNode Parent() {
		if (attribs.Name == "/" && parent)
			return parent.Parent;

		return parent;
	}

	@property List!FSNode Childrens() {
		if (mounts)
			return mounts.Childrens;
		
		LoadContent();
		return childrens;
	}

	this(FileSystemProto fileSystem, FileAttributes fileAttributes) {
		/*const CallTable[] callTable = [
			{FNIF_GETIDXCHILD, &GetIdxChildSC},
			{FNIF_GETNAME, &GetNameChildSC}
		];*/
		//AddCallTable(callTable);

		childrens    = new List!FSNode();
		attribs      = fileAttributes;
		fs           = fileSystem;
		attribs.Type = FileType.Directory;
		super();
	}

	~this() {
		if (attribs.Name == "/" && parent)
			(cast(DirectoryNode)parent).Unmount();

		delete childrens;
	}

	void Unmount() {
		mounts = null;
		attribs.Type = FileType.Directory;
	}

	bool Mount(DirectoryNode childRoot) {
		if (Mountpointable()) {
			childRoot.parent = this;
			mounts           = childRoot;
			attribs.Type     = FileType.Mountpoint;
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
		isLoaded = ret;
		return ret;
	}

	bool Mountpointable() {
		if (!LoadContent())
			return false;

		return !childrens.Count;
	}

	FSNode GetChild(string name) {
		if (mounts)
			return mounts.GetChild(name);

		if (!LoadContent())
			return null;

		foreach (x; childrens)
			if (x.GetAttributes().Name == name)
				return x;

		return null;
	}

	FSNode Create(FileType type, FileAttributes fileAttributes) {		
		if (mounts)
			return mounts.Create(type, fileAttributes);

		if (fs is null)
			return null;

		return fs.Create(this, type, fileAttributes);
	}

	bool Remove(FSNode child) {
		if (mounts)
			return mounts.Remove(child);

		if (!LoadContent())
			return false;

		ulong id = childrens.IndexOf(child);
		if (id == -1)
			return false;

		if (fs != childrens[id].FileSystem)
			return false;

		if (fs !is null && fs.Remove(this, child))
			return false;

		childrens.RemoveAt(id);
		return true;
	}

	void AddNode(FSNode node) {
		if (mounts)
			mounts.AddNode(node);
		
		childrens.Add(node);
		node.parent = this;
	}


	//Syscalls
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