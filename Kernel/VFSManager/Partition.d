module VFSManager.Partition;

import Core.DeviceManager;
import Devices.BlockDeviceProto;
import VFSManager.FSNode;
import VFSManager.BlockNode;
import VFSManager.BlockCache;

import System.IO.FileAttributes;
import System.Collections.Bitfield;


class Partition : BlockNode {
private:
	struct MBREntryT {
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
    };

	BlockDeviceProto dev;
	BlockCache cache;
	ulong start, count;
	

public:
	BlockDeviceProto GetDevice() { return dev; }
	@property ulong StartBlock() { return start; }
	override @property ulong Blocks() const { return count; }
	override @property uint BlockSize() const { return dev.BlockSize; }


    static void ReadTable(BlockDeviceProto dev) {
    	DeviceManager.DevFS.AddNode(new Partition(dev, 0, dev.Blocks, FSNode.NewAttributes("hd" ~ Letter)));

    	byte[] mbr = new byte[512];
    	if (!dev.Read(0, mbr))
    		return;

    	MBREntryT* entry = cast(MBREntryT *)(cast(ulong)mbr.ptr + 0x1BE);

        foreach (i; 0 .. 4) {
    		if ((entry[i].Bootable == 0 || entry[i].Bootable == 0x80) && entry[i].ID
    			&& entry[i].StartLBA && entry[i].Size && entry[i].StartLBA < dev.Blocks
    			&& entry[i].Size < dev.Blocks)
    			DeviceManager.DevFS.AddNode(new Partition(dev, entry[i].StartLBA, entry[i].Size, FSNode.NewAttributes("hd" ~ Letter ~ cast(char)('1' + i))));
    	}

    	Letter++;
       // delete mbr; TODO: fixme
    }

	private this(BlockDeviceProto dev, ulong start, ulong count, FileAttributes fileAttributes) {
		cache       = new BlockCache(dev, 0x10000);
		this.dev    = dev;
		this.start  = start;
		this.count  = count;

		super(fileAttributes);
	}

	override ulong Read(ulong offset, byte[] data) {
		return cache.Read(offset + this.start, data);
	}

	override ulong Write(ulong offset, byte[] data) {
		return cache.Write(offset + this.start, data);
	}
}