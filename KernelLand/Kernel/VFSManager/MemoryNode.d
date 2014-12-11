module VFSManager.MemoryNode;

import VFSManager;


public class MemoryNode : FSNode {
	private byte[] _buffer;

	public this(byte[] buffer, DirectoryNode parent, FileAttributes fileAttributes) {
		_buffer          = buffer;
		_attributes      = fileAttributes;
		_attributes.Type = FileType.CharDevice;
		
		super(parent);
	}
	
	public override ulong Read(long offset, byte[] data) {
		if (offset > _buffer.length)
			return 0;

		long len = offset + data.length > _buffer.length ? _buffer.length - offset : data.length;
		data[] = (cast(byte *)_buffer)[offset .. len];

		return len;
	}
	
	public override ulong Write(long offset, byte[] data) {
		if (offset > _buffer.length)
			return 0;
		
		long len = offset + data.length > _buffer.length ? _buffer.length - offset : data.length;
		(cast(byte *)_buffer)[offset .. len] = data[];

		return len;
	}
}