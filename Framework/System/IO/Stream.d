module System.IO.Stream;


abstract class Stream {
	public ulong id;
	
	@property bool CanRead();
	@property bool CanSeek();
	@property bool CanTimeout();
	@property bool CanWrite();
	@property long Length();
	@property void Length(long value);
	@property long Position();
	@property long ReadTimeout();
	@property void ReadTimeout(long value);
	@property long WriteTimeout();
	@property void WriteTimeout(long value);

	protected this() {}

	void Close();
	void CopyTo(Stream destination);
	void CopyTo(Stream destination, long bufferSize);
	void Flush();

	long Read(byte[] buffer, long offset);
	byte ReadByte();

	long Seek(long offset);
	long SetLength(long value);

	void Write(byte[] buffer, long offset);
	void WriteByte(byte value);
}