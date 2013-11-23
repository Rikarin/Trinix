module System.IO.FileStream;

import System.IO;

import System.IFace;
import System.ResourceCaller;


class FileStream : Stream {
private:
	ResourceCaller syscall;
	FileAttributes attribs;


	ref FileAttributes Reload() {
		ulong[1] tmp = [cast(ulong)&attribs];
		syscall.Call(IFace.FSNode.RATTRIBUTES, tmp);
		return attribs;
	}

	void WriteAttribs() {
		ulong[1] tmp = [cast(ulong)&attribs];
		syscall.Call(IFace.FSNode.WATTRIBUTES, tmp);	
	}


public:
	@property override bool CanRead() { return false; }
	@property override bool CanSeek() { return false; }
	@property override bool CanTimeout() { return false; }
	@property override bool CanWrite() { return false; }

	@property override long Length() {
		return Reload().Length;
	}

	@property override void Length(long value) {}
	@property override long Position() { return 0; }
	@property override long ReadTimeout() { return 0; }
	@property override void ReadTimeout(long value) {}
	@property override long WriteTimeout() { return 0; }
	@property override void WriteTimeout(long value) {}


	this(string path) {
		ulong[2] tmp = [IFace.VFS.S_FIND, cast(ulong)&path];
		id = ResourceCaller.StaticCall(IFace.VFS.OBJECT, tmp);
	
		if (!id) {
			tmp = [IFace.VFS.S_MK_FILE, cast(ulong)&path];
			id = ResourceCaller.StaticCall(IFace.VFS.OBJECT, tmp);
		}
		
		syscall = new ResourceCaller(id, IFace.FSNode.OBJECT);
	}

	//todo fix
	this(ulong id) {
		this.id = id;
		syscall = new ResourceCaller(id, IFace.FSNode.OBJECT);
	}

	ulong ResID() { return syscall.ResID(); }

	override void Close() {}
	override void CopyTo(Stream destination) {}
	override void CopyTo(Stream destination, long bufferSize) {}
	override void Flush() {}

	override long Read(byte[] buffer, long offset) {
		ulong[2] tmp = [offset, cast(ulong)&buffer];
		return syscall.Call(IFace.FSNode.READ, tmp);
	}

	override byte ReadByte() {
		byte[1] b;
		ulong[2] tmp = [0, cast(ulong)&b];		

		if (syscall.Call(IFace.FSNode.READ, tmp))
			return b[0];
		else
			return 0;
	}

	override long Seek(long offset) { return 0; }
	override long SetLength(long value) { return 0; }

	override void Write(byte[] buffer, long offset) {
		ulong[2] tmp = [offset, cast(ulong)&buffer];
		syscall.Call(IFace.FSNode.WRITE, tmp);
	}

	override void WriteByte(byte value) {
		byte[1] b = [value];
		ulong[2] tmp = [0, cast(ulong)&b];
		syscall.Call(IFace.FSNode.READ, tmp);
	}
}