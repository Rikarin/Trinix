module System.IO.Directory;

import System.IO.FileStream;
import System.ResourceCaller;
import System.IFace;


static class Directory {
static:
	void CreateDirectory(string path) {

	}

	FileStream CreatePipe() {
		return new FileStream(ResourceCaller.StaticCall(IFace.FSNode.OBJECT, [IFace.FSNode.SMKPIPE]));
	}
}