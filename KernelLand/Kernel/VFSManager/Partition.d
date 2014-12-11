module VFSManager.Partition;

import Library;
import VFSManager;
import ObjectManager;


public final class Partition : BlockNode {
	private __gshared char[] _diskName = cast(char[])"disk0";

	private BlockCache _cache;
	private long _offset;
	private long _length;

	private struct MBREntry {
	align(1):
		ubyte Bootable;
		ubyte StartHead;
		private ushort _startSC;
		ubyte ID;
		ubyte EndHead;
		private ushort _endSC;
		uint StartLBA;
		uint Size;

		mixin(Bitfield!(_startSC, "StartSector", 6, "StartCylinder", 10));
		mixin(Bitfield!(_endSC, "EndSector", 6, "EndCylinder", 10));
	}

	@property private static string NextDiskName() {
		char[] ret = _diskName.dup;
		_diskName[$ - 1]++;

		return cast(string)ret;
	}

	@property public IBlockDevice Device() {
		return _cache.Device;
	}

	@property public override long Blocks() {
		return _length;
	}
	@property public override long BlockSize() {
		return _cache.Device.BlockSize;
	}

	public this(IBlockDevice device, long offset, long length, DirectoryNode parent, FileAttributes attributes) {
		_cache  = new BlockCache(device, 0x1);
		_offset = offset;
		_length = length;

		super(parent, attributes);
	}

	public ~this() {
		delete _cache;
	}

	public override ulong Read(long offset, byte[] data) {
		if (offset > _length)
			return 0;
		
		long len = offset + data.length > _length ? _length - offset : data.length;
		return Device.Read(_offset + offset, data[0 .. len]); //TODO: cache
	}

	public override ulong Write(long offset, byte[] data) {
		if (offset > _length)
			return 0;
		
		long len = offset + data.length > _length ? _length - offset : data.length;
		return Device.Write(_offset + offset, data[0 .. len]); //TODO: cache
	}

	public static void ReadTable(IBlockDevice device) {
		string name = NextDiskName;
		new Partition(device, 0, device.Blocks, DeviceManager.DevFS, FSNode.NewAttributes(name));

		byte[512] mbr;
		if (device.Read(0, mbr) != 512)
			return;

		MBREntry* entry = cast(MBREntry *)(cast(ulong)mbr.ptr + 0x1BE);
		foreach (i, x; entry[0 .. 4]) {
			if ((x.Bootable == 0 || x.Bootable == 0x80) && x.ID && x.StartLBA < device.Blocks && x.Size < device.Blocks)
				new Partition(device, x.StartLBA, x.Size, DeviceManager.DevFS, FSNode.NewAttributes(name ~ 's' ~ cast(char)('1' + i)));
		}
	}
}