module System.IO.Directory;

import System;
import System.IO;

import System.ResourceCaller;
import System.IFace;


static class Directory {
static:
	void CreateDirectory(string path) {

	}

	FileStream CreatePipe() {
		return new FileStream(ResourceCaller.StaticCall(IFace.VFS.OBJECT, [IFace.VFS.S_MK_PIPE]));
	}

	FileStream CreatePipe(string path) {
		ulong[2] tmp = [IFace.VFS.S_MK_PIPE, cast(ulong)&path];
		return new FileStream(ResourceCaller.StaticCall(IFace.VFS.OBJECT, tmp));
	}
}