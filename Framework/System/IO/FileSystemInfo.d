module System.IO.FileSystemInfo;

import System.IO.FileAttributes;
import System.DateTime;
import System.String;

import System.IFace;
import System.ResourceCaller;


abstract class FileSystemInfo {
private:
	protected ResourceCaller syscall;
	FileAttributes atribs = cast(FileAttributes)~0UL;
	DateTime atime, mtime, ctime;
	string fullName, name, extension;


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
		if (syscall is null)
			return "fix me";
		if (fullName is null) {
			char[] tmp = new char[256];
			ulong length = cast(ulong *)syscall.Call(IFace.FSNode.GETPATH, [cast(ulong)tmp.ptr, tmp.length]);
			fullName = cast(string)([] ~ tmp[0 .. length]);
		}

		return fullName;
	}

	@property string Name() {
		if (name is null)
			name = FullName[String.LastIndexOf(FullName, '/') + 1 .. $];

		return name;
	}

	@property string Extension() {
		if (extension is null)
			extension = Name[String.LastIndexOf(Name, '.') .. $];

		return extension;
	}

	@property bool Exists() {
		if (syscall !is null && syscall.Call(0) == syscall.ResType)
			return true;

		return false;
	}


	void Refresh() {
		atribs    = cast(FileAttributes)~0UL;
		atime     = null;
		mtime     = null;
		ctime     = null;
		fullName  = null;
		name      = null;
		extension = null;
	}

	void Delete() {
		syscall.Call(IFace.FSNode.REMOVE);
	}
}