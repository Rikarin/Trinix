module VFSManager.Partition;

import Devices.BlockDeviceProto;
import VFSManager.BlockCache;


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
		cache       = new BlockCache(dev, 0x10000);
		this.dev    = dev;
		this.number = number;
		this.start  = start;
		this.count  = count;
	}

	ulong Read(ulong offset, byte[] data) {
		return cache.Read(offset + this.start, data);
	}

	ulong Write(ulong offset, byte[] data) {
		return cache.Write(offset + this.start, data);
	}
}