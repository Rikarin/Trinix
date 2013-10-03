module System.IO.DirectoryInfo;

import System.ResourceCaller;
import System.IFace;
import System.IO.FileSystemInfo;


class DirectoryInfo : FileSystemInfo {


	this() {
		//syscall = new ResourceCaller(null, IFace.FSNode.OBJECT);
	}

	~this() {
		delete syscall;
	}
}