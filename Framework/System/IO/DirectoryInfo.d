module System.IO.DirectoryInfo;

import System.ResourceCaller;
import System.IFace;
import System.IO.FileSystemInfo;
import System.Collections.Generic.All;
import System.String;


class DirectoryInfo : FileSystemInfo {
private:
	string tmpLink;

public:
	@property DirectoryInfo Parent() {
		return null;
	}

	@property DirectoryInfo Root() {
		return null;
	}


	this(string path) {
		ulong id = ResourceCaller.StaticCall(IFace.FSNode.OBJECT, [IFace.FSNode.SFIND, cast(ulong)&path]);
	
		if (id)
			syscall = new ResourceCaller(id, IFace.FSNode.OBJECT);
		else
			tmpLink = path;
	}

	~this() {
		delete syscall;
	}

	void Create() {
		ulong id = ResourceCaller.StaticCall(IFace.FSNode.OBJECT, [IFace.FSNode.SFIND, cast(ulong)&tmpLink]);
		
		if (!id) {
			string tmp = tmpLink[String.LastIndexOf(tmpLink, '/') .. $];
			//id = ResourceCaller.StaticCall(IFace.FSNode.OBJECT, [IFace.FSNode.SMKDIR, cast(ulong)&tmp]);

			//if (!id)
			//	syscall = new ResourceCaller(id, IFace.FSNode.OBJECT);
		}	
	}

	DirectoryInfo CreateSubdirectory(string path) {
		return null;
	}

	//void Delete(bool recursive) {

	//}

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