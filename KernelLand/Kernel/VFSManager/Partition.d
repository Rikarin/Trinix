module VFSManager.Partition;

import Library;
import VFSManager;
import ObjectManager;


public final class Partition : BlockNode {
	private BlockCache _cache;
	private long _index;
	private long _offset;

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

	@property public IBlockDevice Device() {
		return _cache.Device;
	}

	@property public override long Blocks() {
		return _offset;
	}
	@property public override long BlockSize() {
		return _cache.Device.BlockSize;
	}

	public this(IBlockDevice device, long index, long offset, DirectoryNode parent, FileAttributes attributes) {
		_cache  = new BlockCache(device, 0x1);
		_index  = index;
		_offset = offset;

		super(parent, attributes);
	}

	public override ulong Read(long offset, byte[] data) {
		if (_index + offset + data.length > _index + _offset)
			return 0;

		//TODO: return _cache.Read(offset + _index, data);
		return Device.Read(offset + _index, data);
	}

	public override ulong Write(long offset, byte[] data) {
		if (_index + offset + data.length > _index + _offset)
			return 0;

		//TODO: return _cache.Write(offset + _index, data);
		return Device.Write(offset + _index, data);
	}

	public static void ReadTable(IBlockDevice device) {
		new Partition(device, 0, device.Blocks, DeviceManager.DevFS, FSNode.NewAttributes("hd" ~ Letter));

		byte[512] mbr;
		if (device.Read(0, mbr) != 512)
			return;

		MBREntry* entry = cast(MBREntry *)(cast(ulong)mbr.ptr + 0x1BE);
		foreach (i, x; entry[0 .. 4]) {
			if ((x.Bootable == 0 || x.Bootable == 0x80) && x.ID && x.StartLBA < device.Blocks && x.Size < device.Blocks)
				new Partition(device, x.StartLBA, x.Size, DeviceManager.DevFS, FSNode.NewAttributes("hd" ~ Letter ~ cast(char)('1' + i)));
		}

		Letter++;
	}
}