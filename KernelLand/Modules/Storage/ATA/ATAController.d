module Modules.Storage.ATA.ATAController;

static import Architecture;

import Library;
import VFSManager;
import Modules.Storage.ATA.ATADrive;


public class ATAController {
	private uint _base;
	private ubyte _number;
	private ATADrive[2] _drives;
	private SpinLock _spinLock; //TODO: mutex?

	package enum Base {
		Bus1 = 0x1F0,
		Bus2 = 0x170
	}
	
	package enum Port : short {
		Data,
		FeaturesError,
		SectCount,
		Partial1,
		Partial2,
		Partial3,
		DriveSelect,
		Command
	}
	
	package enum Cmd {
		Identify = 0xEC,
		Read     = 0x20,
		Write    = 0x30
	}

	package void Lock() {
		_spinLock.WaitOne();
	}

	package void Unlock() {
		_spinLock.Release();
	}

	package T Read(T)(short port) {
		return cast(T)Architecture.Port.Read!T(cast(short)(_base + port));
	}

	package void Write(T)(short port, T value) {
		Architecture.Port.Write!T(cast(short)(_base + port), value);
	}

	private this(uint base, ubyte number) {
		_spinLock  = new SpinLock();
		_base      = base;
		_number    = number;

		Identity(false);
		Identity(true);
	}

	public ~this() {
		delete _drives[0];
		delete _drives[1];
		delete _spinLock;
	}

	private void Identity(bool isSlave) {
		if (_drives[isSlave ? 1 : 0])
			return;

		Write!byte(Port.DriveSelect, cast(byte)(isSlave ? 0xB0 : 0xA0));
		Write!byte(Port.Command, cast(byte)Cmd.Identify);
		byte ret = Read!byte(Port.Command);

		if (!ret)
			return;

		while ((ret & 0x88) != 0x08 && (ret & 1) != 1)
			ret = Read!byte(Port.Command);

		if ((ret & 1) == 1)
			return;

		short[] data = new short[256];
		foreach (ref x; data)
			x = Read!short(Port.Data);

		uint blocks = (data[61] << 16) | data[60];
		if (blocks)
			_drives[isSlave ? 1 : 0] = new ATADrive(this, isSlave, blocks, data);
		else
			delete data;
	}

	public static ATAController[2] Detect() {
		ATAController[2] c;
		c[0] = new ATAController(Base.Bus1, 0);
		c[1] = new ATAController(Base.Bus2, 1);

		foreach (x; c) {
			foreach (y; x._drives) {
				if (y !is null)
					Partition.ReadTable(y);
			}
		}

		return c;
	}
}