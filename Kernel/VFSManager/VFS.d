module VFSManager.VFS;

import VFSManager.DirectoryNode;
//import VFSManager

class VFS {
public:
static:
	__gshared DirectoryNode Root;


	bool Init() {
		Root = new DirectoryNode("/", null);
		return true;
	}
}