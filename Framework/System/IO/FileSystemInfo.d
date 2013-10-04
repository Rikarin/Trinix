module System.IO.FileSystemInfo;

import System.IO.FileAttributes;
import System.DateTime;
import System.String;

import System.IFace;
import System.ResourceCaller;


abstract class FileSystemInfo {
private:
	FileAttributes atribs = cast(FileAttributes)~0UL;
	DateTime atime, mtime, ctime;
	string fullName, name, extension;


protected:
	ResourceCaller syscall;

	this() { }


public:
	@property FileAttributes Attributes() {
		if (atribs == cast(FileAttributes)~0UL)
			atribs = cast(FileAttributes)syscall.Call(IFace.FSNode.GETPERM);

		return atribs;
	}

	@property void Attributes(FileAttributes attributes) {
		atribs = attributes;
		syscall.Call(IFace.FSNode.SETPERM, [cast(ulong)attributes]);
	}


	@property DateTime LastAccessTime() {
		if (atime is null)
			atime = new DateTime(syscall.Call(IFace.FSNode.GETATIME));	

		return atime;
	}

	@property void LastAccessTime(DateTime date) {
		atime = date;
		syscall.Call(IFace.FSNode.SETATIME, [date.Ticks]);
	}

	@property DateTime LastModifyTime() {
		if (mtime is null)
			mtime = new DateTime(syscall.Call(IFace.FSNode.GETMTIME));

		return mtime;
	}

	@property void LastModifyTime(DateTime date) {
		mtime = date;
		syscall.Call(IFace.FSNode.SETMTIME, [date.Ticks]);
	}

	@property DateTime CreationTime() {
		if (ctime is null)
			ctime = new DateTime(syscall.Call(IFace.FSNode.GETCTIME));

		return ctime;
	}

	@property void CreationTime(DateTime date) {
		ctime = date;
		syscall.Call(IFace.FSNode.SETCTIME, [date.Ticks]);
	}

	@property string FullName() {
		return *cast(string *)syscall.Call(IFace.FSNode.GETPATH);
	}

	@property string Name() {
		return String.Substring(FullName, String.LastIndexOf(FullName, '/'));
	}

	@property string Extension() {
		return String.Substring(Name, String.LastIndexOf(Name, '.'));
	}
}