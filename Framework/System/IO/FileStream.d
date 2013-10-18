module System.IO.FileStream;

import System.IO.Stream;
import System.ResourceCaller;
import System.IFace;


class FileStream : Stream {
private:
	ResourceCaller syscall;


public:
	@property override bool CanRead() { return false; }
	@property override bool CanSeek() { return false; }
	@property override bool CanTimeout() { return false; }
	@property override bool CanWrite() { return false; }
	@property override long Length() { return 0; }
	@property override void Length(long value) {}
	@property override long Position() { return 0; }
	@property override long ReadTimeout() { return 0; }
	@property override void ReadTimeout(long value) {}
	@property override long WriteTimeout() { return 0; }
	@property override void WriteTimeout(long value) {}


	this(string path) {
		id = ResourceCaller.StaticCall(IFace.FSNode.OBJECT, [IFace.FSNode.SFIND, cast(ulong)&path]);
	
		if (!id)
			id = ResourceCaller.StaticCall(IFace.FSNode.OBJECT, [IFace.FSNode.SMKFILE, cast(ulong)&path]);	
		
		syscall = new ResourceCaller(id, IFace.FSNode.OBJECT);
	}

	//todo fix
	this(ulong id) {
		this.id = id;
		syscall = new ResourceCaller(id, IFace.FSNode.OBJECT);
	}

	override void Close() {}
	override void CopyTo(Stream destination) {}
	override void CopyTo(Stream destination, long bufferSize) {}
	override void Flush() {}

	override long Read(byte[] buffer, long offset) {
		return syscall.Call(IFace.FSNode.READ, [offset, cast(ulong)&buffer]);
	}

	override byte ReadByte() {
		byte[1] b;
		if (syscall.Call(IFace.FSNode.READ, [0, cast(ulong)&b]))
			return b[0];
		else
			return 0;
	}

	override long Seek(long offset) { return 0; }
	override long SetLength(long value) { return 0; }

	override void Write(byte[] buffer, long offset) {
		syscall.Call(IFace.FSNode.WRITE, [offset, cast(ulong)&buffer]);
	}

	override void WriteByte(byte value) {
		byte[1] b = [value];
		syscall.Call(IFace.FSNode.READ, [0, cast(ulong)&b]);
	}
}