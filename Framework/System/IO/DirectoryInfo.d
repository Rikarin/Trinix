module System.IO.DirectoryInfo;

import System.ResourceCaller;
import System.IFace;
import System.IO.FileSystemInfo;
import System.Collections.Generic.All;


class DirectoryInfo : FileSystemInfo {
	@property DirectoryInfo Parent() {
		return null;
	}

	@property DirectoryInfo Root() {
		return null;
	}


	this(string path) {
		ulong id = ResourceCaller.StaticCall(IFace.FSNode.OBJECT, [IFace.FSNode.SFIND, cast(ulong)&path]);
		syscall = new ResourceCaller(10, IFace.FSNode.OBJECT);
	}

	~this() {
		delete syscall;
	}

	void Create() {

	}

	DirectoryInfo CreateSubdirectory(string path) {
		return null;
	}

	void Delete(bool recursive) {

	}

	List!DirectoryInfo EnumerateDirectories() {
		return null;
	}

	List!DirectoryInfo EnumerateDirectories(string searchPattern) {
		return null;
	}

	/*List!FileInfo EnumerateFiles() {
		return null;
	}

	List!FileInfo EnumerateFiles(string searchPattern) {
		return null;
	}*/

	List!FileSystemInfo EnumerateFileSystemInfos() {
		return null;
	}
}