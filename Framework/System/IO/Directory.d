module System.IO.Directory;

import System.IO.FileStream;
import System.ResourceCaller;
import System.IFace;
import System.String;


static class Directory {
static:
	void CreateDirectory(string path) {

	}

	FileStream CreatePipe() {
		return new FileStream(ResourceCaller.StaticCall(IFace.FSNode.OBJECT, [IFace.FSNode.SMKPIPE]));
	}

	FileStream CreatePipe(string path) {
		return new FileStream(ResourceCaller.StaticCall(IFace.FSNode.OBJECT, [IFace.FSNode.SMKPIPE, cast(ulong)&path]));
	}
}