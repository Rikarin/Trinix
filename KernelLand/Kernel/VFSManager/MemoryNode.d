module VFSManager.MemoryNode;

import VFSManager;


public class MemoryNode : FSNode {
	private void* _buffer;
	private long _length;

	public this(void* buffer, long length, DirectoryNode parent, FileAttributes fileAttributes) {
		_buffer          = buffer;
		_length          = length;
		_attributes      = fileAttributes;
		_attributes.Type = FileType.CharDevice;
		
		super(parent);
	}
	
	public override ulong Read(long offset, byte[] data) {
		if (offset + data.length > cast(ulong)_buffer + _length)
			return 0;

		data[] = (cast(byte *)_buffer)[offset .. data.length];
		return data.length;
	}
	
	public override ulong Write(long offset, byte[] data) {
		if (offset + data.length > cast(ulong)_buffer + _length)
			return 0;

		(cast(byte *)_buffer)[offset .. data.length] = data[];
		return data.length;
	}
}