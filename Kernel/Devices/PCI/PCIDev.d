module Devices.PCI.PCIDev;

import Core;
import Devices;
import Devices.PCI;
import Architectures;

import System.Collections;
import System.Collections.Generic;


class PCIDev : DeviceProto {
	struct Common {
	align(1):
        ushort VendorID;
        ushort DeviceID;
        ushort CommandRegister;
        ushort StatusRegister;
        ubyte RevisionID;
        ubyte ProgInterface;
        ubyte Subclass;
        ubyte ClassCode;
        ubyte CachelineSize;
        ubyte Latency;
        ubyte HeaderType;
        ubyte BIST;
    }
    
    struct NonBridge {
	align(1):
        ulong BaseAddress0;
        ulong BaseAddress1;
        ulong BaseAddress2;
        ulong BaseAddress3;
        ulong BaseAddress4;
        ulong BaseAddress5;
        ulong CardBusCIS;
        ushort SubsystemVendorID;
        ushort SubsystemDeviceID;
        ulong ExpansionROM;
        ubyte CapPtr;
        private ubyte reserved1[3];
        private ulong reserved2[1];
        ubyte InterruptLine;
        ubyte InterruptPin;
        ubyte MinGrant;
        ubyte MaxLatency;
        ulong DeviceSpecific[48];
    }
    
    struct Bridge {
    align(1):
        ulong BaseAddress0;
        ulong BaseAddress1;
        ubyte PrimaryBus;
        ubyte SecondaryBus;
        ubyte SubordinateBus;
        ubyte SecondaryLatency;
        ubyte IOBaseLow;
        ubyte IOLimitLow;
        ushort SecondaryStatus;
        ushort MemoryBaseLow;
        ushort MemoryLimitLow;
        ushort PrefetchBaseLow;
        ushort PrefetchLimitLow;
        ulong PrefetchBaseHigh;
        ulong PrefetchLimitHigh;
        ushort IOBaseHigh;
        ushort IOLimitHigh;
        private ulong reserved2[1];
        ulong ExpansionROM;
        ubyte InterruptLine;
        ubyte InterruptPin;
        ushort BridgeControl;
        ulong DeviceSpecific[48];
    }
    
    struct CardBus {
    align(1):
        ulong ExCaBase;
        ubyte CapPtr;
        private ubyte reserved05;
        ushort SecondaryStatus;
        ubyte PCIBus;
        ubyte CardBusBus;
        ubyte SubordinateBus;
        ubyte LatencyTimer;
        ulong MemoryBase0;
        ulong MemoryLimit0;
        ulong MemoryBase1;
        ulong MemoryLimit1;
        ushort IOBase0Low;
        ushort IOBase0High;
        ushort IOLimit0Low;
        ushort IOLimit0High;
        ushort IOBase1Low;
        ushort IOBase1High;
        ushort IOLimit1Low;
        ushort IOLimit1High;
        ubyte InterruptLine;
        ubyte InterruptPin;
        ushort BridgeControl;
        ushort SubsystemVendorID;
        ushort SubsystemDeviceID;
        ulong LegacyBaseaddr;
        private ulong cardbus_reserved[14];
        ulong VendorSpecific[32];
    }
    
    struct ConfAdd {
    align(1):
        ubyte Register;
        private ubyte Flags1;
        ubyte Bus;
        private ubyte Flags2;

        mixin(Bitfield!(Flags1, "Function", 3, "Device", 5));
        mixin(Bitfield!(Flags1, "rsvd", 7, "Enable", 1));
    };
    
    enum BarType {
        BAR_TYPE_MEM = 0,
        BAR_TYPE_IO
    };

    
private:
	private static __gshared List!PCIDev list;

	enum PCI_BASE_REG = 0xCFC;
	enum PCI_DATA_REG = 0xCF8;
	enum PCI_IRQ_LINE = 0x3C;
	enum PCI_IRQ_PIN  = 0x3D;

	enum PCI_BASE_ADDRESS_0            = 0x10;
	enum PCI_BASE_ADDRESS_SPACE        = 0x01;
	enum PCI_BASE_ADDRESS_SPACE_MEMORY = 0x00;
	enum PCI_IO_RESOURCE_MEM           = 0x00;
	enum PCI_IO_RESOURCE_IO            = 0x01;
	enum PCI_BASE_ADDRESS_MEM_MASK     = ~0x0;
	enum PCI_BASE_ADDRESS_IO_MASK      = ~0x03;


    ubyte bus, dev, func;
    Common common;
    uint devi[60];
    
    ubyte irq;
    uint base[6];
    uint size[6];
    ubyte type[6];


public:
	@property ubyte IRQ() { return irq; }
	uint GetBase(byte i) { return base[i]; }
	T Read(T)(int reg) { return cast(T)ReadValue(reg, T.sizeof); }
	void Write(T)(int reg, T value) { WriteValue(reg, value, T.sizeof); }


	this(ubyte bus, ubyte dev, ubyte func, Common cmn) {
		this.bus = bus;
		this.dev = dev;
		this.func = func;
		common = cmn;

		irq = Read!byte(PCI_IRQ_PIN);
		if (irq)
			irq = Read!byte(PCI_IRQ_LINE);

		DeviceManager.RegisterDevice(this, DeviceInfo("Device", DeviceType.PCI));
	}

	uint ReadValue(uint reg, uint ts) {
		ConfAdd c;
		c.Enable   = 1;
		c.Bus      = bus;
		c.Device   = dev;
		c.Function = func;
		c.Register = reg & 0xFC;

		Port.Write!byte(PCI_DATA_REG, *cast(byte *)&c);
		ushort base = PCI_BASE_REG + (reg & 0x03);

		switch (ts) {
			case 1:
				return Port.Read!byte(base);
			case 2:
				return Port.Read!short(base);
			case 3:
				return Port.Read!int(base);
			default:
				return 0;
		}
	}

	void WriteValue(uint reg, int value, uint ts) {
		ConfAdd c;
		c.Enable   = 1;
		c.Bus      = bus;
		c.Device   = dev;
		c.Function = func;
		c.Register = reg & 0xFC;

		Port.Write!byte(PCI_DATA_REG, *cast(byte *)&c);
		ushort base = PCI_BASE_REG + (reg & 0x03);

		final switch (ts) {
			case 1:
				Port.Write!byte(base, cast(byte)value);
				break;
			case 2:
				Port.Write!short(base, cast(short)value);
				break;
			case 3:
				Port.Write!int(base, value);
				break;
		}
	}

	BarType GetBarType(int barNum) {
		int tmp = Read!int(0x10 + (barNum << 2));

		if (tmp & 1)
			return BarType.BAR_TYPE_IO;
		return BarType.BAR_TYPE_MEM;
	}

	uint GetBar(int barNum) {
		int tmp = Read!int(0x10 + (barNum << 2));

		if (tmp & 1)
			return tmp & ~0x03;
		return tmp & ~0x0F;
	}

	uint GetSize(uint base, uint mask) {
		uint ret = base & mask;
		ret = ret & ~(ret - 1);
		return ret - 1;
	}

	void ReadBases(uint count) {
		base[] = 0;
		type[] = 0;
		size[] = 0;

		foreach (i; 0 .. count) {
			byte reg = cast(byte)(PCI_BASE_ADDRESS_0 + (i << 2));
			uint l = Read!byte(reg);
			Write!byte(reg, ~0);

			uint sz = Read!byte(reg);
			Write!byte(reg, 1);

			if (!sz || sz == 0xFFFFFFFF)
				continue;

			if (l == 0xFFFFFFFF)
				l = 0;

			if ((l & PCI_BASE_ADDRESS_SPACE) == PCI_BASE_ADDRESS_SPACE_MEMORY) {
				base[i] = l & PCI_BASE_ADDRESS_MEM_MASK;
				size[i] = GetSize(sz, PCI_BASE_ADDRESS_MEM_MASK);
				type[i] = PCI_IO_RESOURCE_MEM;
			} else {
				base[i] = l & PCI_BASE_ADDRESS_IO_MASK;
				size[i] = GetSize(sz, PCI_BASE_ADDRESS_IO_MASK);
				type[i] = PCI_IO_RESOURCE_IO;
			}
		}
	}


static:
	@property bool IsPresent() { return Port.Read!uint(PCI_DATA_REG) != 0xFFFFFFFF; }

	void ScanDevices() {
		if (!IsPresent)
			return;

		foreach (byte bus; 0 .. 4) {
			foreach (byte dev; 0 .. 32) {
				foreach (byte func; 0 .. 8) {
					uint tmp[4];
					PCIDev pf = new PCIDev(bus, dev, func, cast(Common)0);

					foreach (i; 0 .. 4)
						tmp[i] = pf.Read!uint(i << 2);

					delete pf;
					Common* cfg = cast(Common *)tmp.ptr;
					if (cfg.VendorID == 0xFFFF || !cfg.VendorID)
						continue;

					PCIDev newDev = new PCIDev(bus, dev, func, *cfg);
					foreach (i; 0 .. 60)
						newDev.devi[i] = newDev.Read!uint((i << 2) + 16);

					list.Add(newDev);
				}
			}
		}
	}
}