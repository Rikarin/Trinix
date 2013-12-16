module Devices.Disk.ATADrive;

import Devices;
import Devices.Disk;


class ATADrive : BlockDeviceProto {
private:
	ATAController controller;
	bool slave;
	uint blockCount;
	short[] data;


public:
	override @property ulong Blocks() const { return blockCount; }
	override @property uint BlockSize() const { return 512; }


	this(ATAController controller, bool slave, uint blockCount, short[] data) {
		this.controller = controller;
		this.slave      = slave;
		this.blockCount = blockCount;
		this.data       = data;
	}

	~this() { 
		delete data;
	}

	void CMDCommon(long offset, byte count) {
		controller.Write!byte(ATAController.Port.FeaturesError, 0);
		controller.Write!byte(ATAController.Port.SectCount, count);

		controller.Write!byte(ATAController.Port.Partial1, offset & 0xFF);
		controller.Write!byte(ATAController.Port.Partial2, (offset >> 8) & 0xFF);
		controller.Write!byte(ATAController.Port.Partial3, (offset >> 16) & 0xFF);

		controller.Write!byte(ATAController.Port.DriveSelect, cast(byte)(0xE0 | (slave ? 0x10 : 0) | ((offset >> 24) & 0x0F)));
	}

	override ulong Read(ulong offset, byte[] data) {
		if (offset + (data.length / 512) > blockCount)
			return 0;

		controller.Lock();
		CMDCommon(offset, cast(byte)(data.length / 512));
		controller.Write!byte(ATAController.Port.Command, ATAController.Cmd.Read);
		while (!(controller.Read!byte(ATAController.Port.Command) & 0x08)) { }

		for (long i; i < data.length;) {
			short tmp = controller.Read!short(ATAController.Port.Data);
			data[i++] = tmp & 0xFF;
			data[i++] = tmp >> 8;
		}

		controller.Unlock();
		return data.length;
	}

	override ulong Write(ulong offset, byte[] data) {
		if (offset + data.length / 512 > blockCount)
			return 0;

		controller.Lock();
		CMDCommon(offset, cast(byte)(data.length / 512));
		controller.Write!byte(ATAController.Port.Command, ATAController.Cmd.Write);
		while (!(controller.Read!byte(ATAController.Port.Command) & 0x08)) { }

		for (long i; i < data.length;)
			controller.Write!short(ATAController.Port.Data, cast(byte)(data[i++] | (data[i++] << 8)));

		controller.Unlock();
		return data.length;
	}
}