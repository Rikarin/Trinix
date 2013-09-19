module VFSManager.Part;

import System.Collections.All;
import System.Collections.Generic.All;
import Devices.BlockDeviceProto;
import VFSManager.Partition;
import Architectures.Port;


class Part {
static:
private:	
	struct MBREntryT {
	align(1):
        ubyte Bootable;
        ubyte StartHead;
        ushort _startSC;
        ubyte ID;
        ubyte EndHead;
        ushort _endSC;
        uint StartLBA;
        uint Size;

        mixin(Bitfield!(_startSC, "StartSector", 6, "StartCylinder", 10));
        mixin(Bitfield!(_endSC, "EndSector", 6, "EndCylinder", 10));
    };

    __gshared List!BlockDeviceProto devices;
    __gshared List!Partition partitions;


    void ReadPartTable(BlockDeviceProto dev) {
    	partitions.Add(new Partition(dev, 0, 0, dev.Blocks));

    	byte[] mbr = new byte[512];
    	if (!dev.Read(0UL, mbr))
    		return;

    	MBREntryT* entry = cast(MBREntryT *)(cast(ulong)mbr.ptr + 0x1BE);

        foreach (i; 0 .. 4) {
    		if ((entry[i].Bootable == 0 || entry[i].Bootable == 0x80) && entry[i].ID
    			&& entry[i].StartLBA && entry[i].Size && entry[i].StartLBA < dev.Blocks
    			&& entry[i].Size < dev.Blocks)
    			partitions.Add(new Partition(dev, cast(ubyte)(i + 1), entry[i].StartLBA, entry[i].Size));
    	}

        delete mbr;
    }


public:
	void Register(BlockDeviceProto dev) {
		Unregister(dev);
		Port.Cli();

		ReadPartTable(dev);
		devices.Add(dev);

		Port.Sti();
	}

	void Unregister(BlockDeviceProto dev) {
		Port.Cli();

		foreach (x; partitions) {
			if (x.GetDevice() == dev)
				partitions.Remove(x);
		}

		devices.Remove(dev);
		Port.Sti();
	}
}