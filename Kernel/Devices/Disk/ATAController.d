module Devices.Disk.ATAController;

import Core;
import Devices;
import Devices.Disk;
import VFSManager;
static import Architectures;

import System.Threading;


class ATAController : DeviceProto {
private:
	uint base;
	ubyte number;
	ATADrive drives[2];
	Mutex mutex;


public:
	enum Base {
		Bus1 = 0x1F0,
		Bus2 = 0x170
	}

	enum Port : short {
		Data = 0,
		FeaturesError,
		SectCount,
		Partial1,
		Partial2,
		Partial3,
		DriveSelect,
		Command
	}

	enum Cmd {
		Identify = 0xEC,
		Read     = 0x20,
		Write    = 0x30
	}


	void Lock() { mutex.WaitOne(); }
	void Unlock() { mutex.Release(); }

	T Read(T)(short port) {
		return cast(T)Architectures.Port.Read!T(cast(short)(base + port));
	}

	void Write(T)(short port, T value) {
		Architectures.Port.Write!T(cast(short)(base + port), value);
	}


	this(uint base, ubyte number) {
		mutex = new Mutex();
		this.base = base;
		this.number = number;

		Identify(false);
		Identify(true);
	}

	void Identify(bool slave) {
		if (drives[slave ? 1 : 0])
			return;

		Write!byte(Port.DriveSelect, cast(byte)(slave ? 0xB0 : 0xA0));
		Write!byte(Port.Command, cast(byte)Cmd.Identify);
		byte ret = Read!byte(Port.Command);

		if (!ret)
			return;

		while ((ret & 0x88) != 0x08 && (ret & 1) != 1)
			ret = Read!byte(Port.Command);

		if ((ret & 1) == 1)
			return;

		short[] data = new short[256];
		foreach (i; 0 .. 256)
			data[i] = Read!short(Port.Data);

		uint blocks = (data[61] << 16) | data[60];
		if (blocks)
			drives[slave ? 1 : 0] = new ATADrive(this, slave, blocks, data);
	}

	static void Detect() {
		ATAController c[2];
		c[0] = new ATAController(Base.Bus1, 0);
		c[1] = new ATAController(Base.Bus2, 1);

		DeviceManager.RegisterDevice(c[0], DeviceInfo("ATA Controller #1", DeviceType.BlockDevice));
		DeviceManager.RegisterDevice(c[1], DeviceInfo("ATA Controller #2", DeviceType.BlockDevice));

		foreach (i; 0 .. 2) {
			foreach (j; 0 .. 2) {
				ATADrive d = c[i].drives[j];

				if (d) {
					Partition.ReadTable(d);
					DeviceManager.RegisterDevice(d, DeviceInfo("ATA Driver " ~ (i ? "#1 " : "#2") ~ 
					(j ? "Master" : "Slave"), DeviceType.BlockDevice));
				}
			}
		}
	}
}