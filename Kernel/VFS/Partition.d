module VFS.Partition;

import Devices.BlockDeviceProto;
import VFS.BlockCache;


class Partition {
private:
	BlockDeviceProto dev;
	BlockCache cache;
	ulong start, count;
	ubyte number;

public:
	BlockDeviceProto GetDevice() { return dev; }
	@property ulong StartBlock() { return start; }
	@property ulong Count() { return count; }
	@property ubyte PartitionNumber() { return number; }
	@property uint BlockSize() { return dev.BlockSize; }


	this(BlockDeviceProto dev, ubyte number, ulong start, ulong count) {
		cache = new BlockCache(dev);

		this.dev = dev;
		this.number = number;
		this.start = start;
		this.count = count;
	}

	bool Read(ulong start, out byte[] data) {
		return cache.Read(start + this.start, data);
	}

	bool Write(ulong start, in byte[] data) {
		return cache.Write(start + this.start, data);
	}
}