module VFSManager.Partition;

import Core;
import Drivers;
import VFSManager;

import System.IO;
import System.Collections;


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

        foreach (i, ref x; entry[0 .. 4]) {
    		if ((x.Bootable == 0 || x.Bootable == 0x80) && x.ID
    			&& x.StartLBA && x.Size && x.StartLBA < dev.Blocks
    			&& x.Size < dev.Blocks)
    			DeviceManager.DevFS.AddNode(new Partition(dev, x.StartLBA, x.Size, FSNode.NewAttributes("hd" ~ Letter ~ cast(char)('1' + i))));
    	}

    	Letter++;
        //TODO delete mbr;
    }

	private this(BlockDeviceProto dev, ulong start, ulong count, FileAttributes fileAttributes) {
		//cache       = new BlockCache(dev, 0x10000);
		this.dev    = dev;
		this.start  = start;
		this.count  = count;

		super(fileAttributes);
	}

	override ulong Read(ulong offset, byte[] data) {
        if (offset + start > start + count)
            return 0;

		return dev.Read(offset + start, data);
	}

	override ulong Write(ulong offset, byte[] data) {
        if (offset + start > start + count)
            return 0;

		return dev.Write(offset + start, data);
	}
}