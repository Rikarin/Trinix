module System.IO.DirectoryInfo;

import System.ResourceCaller;
import System.IFace;
import System.IO.FileSystemInfo;


class DirectoryInfo : FileSystemInfo {


	this(ulong test) {
		syscall = new ResourceCaller(test, IFace.FSNode.OBJECT);
	}

	~this() {
		delete syscall;
	}
}