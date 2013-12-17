module Drivers.Bus.PCI.PCIDev;

import Core;
import Drivers;
import Drivers.Bus.PCI;
import Architectures;

import System;
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
        ubyte SubClass;
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
        mixin(Bitfield!(Flags2, "rsvd", 7, "Enable", 1));
    };
    
    enum BarType {
        Memory = 0,
        IO
    };

    
private:
	enum BaseRegister = 0xCFC;
	enum DataRegister = 0xCF8;
	enum IRQLine      = 0x3C;
	enum IRQPin       = 0x3D;

	enum BaseAddress0           = 0x10;
	enum BaseAddressSpace       = 0x01;
	enum BaseAddressSpaceMemory = 0x00;
	enum IOResourceMemory       = 0x00;
	enum IOResourceIO           = 0x01;
	enum BaseAddressMemoryMask  = ~0x0;
	enum BaseAddressIOMask      = ~0x03;


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

		irq = Read!byte(IRQPin);
		if (irq)
			irq = Read!byte(IRQLine);

		DeviceManager.RegisterDevice(this, DeviceInfo(ClassName, DeviceType.PCI));
	}

	uint ReadValue(int reg, int ts) {
		ConfAdd c;
		c.Enable   = 1;
		c.Bus      = bus;
		c.Device   = dev;
		c.Function = func;
		c.Register = reg & 0xFC;

		Port.Write!uint(DataRegister, *cast(uint *)&c);
		ushort base = BaseRegister + (reg & 0x03);

		switch (ts) {
			case 1:
				return Port.Read!ubyte(base);
			case 2:
				return Port.Read!ushort(base);
			case 4:
				return Port.Read!uint(base);
			default:
				return 0;
		}
	}

	void WriteValue(int reg, int value, int ts) {
		ConfAdd c;
		c.Enable   = 1;
		c.Bus      = bus;
		c.Device   = dev;
		c.Function = func;
		c.Register = reg & 0xFC;

		Port.Write!uint(DataRegister, *cast(uint *)&c);
		ushort base = BaseRegister + (reg & 0x03);

		final switch (ts) {
			case 1:
				Port.Write!ubyte(base, cast(byte)value);
				break;
			case 2:
				Port.Write!ushort(base, cast(short)value);
				break;
			case 4:
				Port.Write!uint(base, value);
				break;
		}
	}

	BarType GetBarType(int barNum) {
		int tmp = Read!uint(0x10 + (barNum << 2));

		if (tmp & 1)
			return BarType.IO;
		return BarType.Memory;
	}

	uint GetBar(int barNum) {
		int tmp = Read!uint(0x10 + (barNum << 2));

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
			uint reg = cast(byte)(BaseAddress0 + (i << 2));
			ubyte l = Read!byte(reg);
			Write!byte(reg, ~0);

			ubyte sz = Read!byte(reg);
			Write!byte(reg, 1);

			if (!sz || sz == 0xFFFFFFFF)
				continue;

			if (l == 0xFFFFFFFF)
				l = 0;

			if ((l & BaseAddressSpace) == BaseAddressSpaceMemory) {
				base[i] = l & BaseAddressMemoryMask;
				size[i] = GetSize(sz, BaseAddressMemoryMask);
				type[i] = IOResourceMemory;
			} else {
				base[i] = l & BaseAddressIOMask;
				size[i] = GetSize(sz, BaseAddressIOMask);
				type[i] = IOResourceIO;
			}
		}
	}

	@property string Vendor() {
		foreach (x; VendorArray) {
			if (x.Identifier == common.VendorID)
				return x.Name;
		}

		return "Unknown vendor";
	}

	@property string VendorDevice() {
		foreach (x; BusDeviceNames) {
			if (x.Vendor == common.VendorID && x.Device == common.DeviceID)
				return x.Name;
		}

		return "Unknown device";
	}

	@property string ClassName() {
		uint code = (common.ClassCode << 8) + common.SubClass;
    
		switch (code) {
			case PCIClass.NotDefined: return "Unknown device/VGA";
			case PCIClass.NotDefinedVGA: return "Unknown/VGA";
			case PCIClass.Storage.SCSI: return "SCSI-Disk";
			case PCIClass.Storage.IDE: return "IDE-Disk";
			case PCIClass.Storage.Floppy: return "Floppy-Disk";
			case PCIClass.Storage.IPI: return "IPI-Disk";
			case PCIClass.Storage.RAID: return "RAID";
			case PCIClass.Storage.SATA: return "SATA";
			case PCIClass.Storage.SATA_AHCI: return "SATA AHCI";
			case PCIClass.Storage.SAS: return "SAS";
			case PCIClass.Storage.Other: return "Other Storage";

			case PCIClass.Network.Ethernet: return "Ethernet";
			case PCIClass.Network.TokenRing: return "Tokenring";
			case PCIClass.Network.FDDI: return "FDDI";
			case PCIClass.Network.ATM: return "ATM";
			case PCIClass.Network.Other: return "Other";

			case PCIClass.Display.VGA: return "VGA";
			case PCIClass.Display.XGA: return "XGA";
			case PCIClass.Display.N3D: return "3D";
			case PCIClass.Display.Other: return "Other Disp";

			case PCIClass.Multimedia.Video: return "Video";
			case PCIClass.Multimedia.Audio: return "Audio";
			case PCIClass.Multimedia.Phone: return "Phone";
			case PCIClass.Multimedia.Other: return "Other Mmedia";

			case PCIClass.Memory.RAM: return "RAM";
			case PCIClass.Memory.Flash: return "FLASH";
			case PCIClass.Memory.Other: return "Other Mem";

			case PCIClass.Bridge.Host: return "Host Bridge";
			case PCIClass.Bridge.ISA: return "ISA Bridge";
			case PCIClass.Bridge.EISA: return "EISA Bridge";
			case PCIClass.Bridge.MC: return "MC Bridge";
			case PCIClass.Bridge.PCI: return "PCI Bridge";
			case PCIClass.Bridge.PCMCIA: return "PCMCIA Bridge";
			case PCIClass.Bridge.NuBUS: return "NUBUS Bridge";
			case PCIClass.Bridge.CardBus: return "CardBus Bridge";
			case PCIClass.Bridge.Raceway: return "Raceway Bridge";
			case PCIClass.Bridge.Other: return "Other Bridge";

			case PCIClass.Communication.Serial: return "Serial";
			case PCIClass.Communication.Parallel: return "Parallel";
			case PCIClass.Communication.MSerial: return "MultiSerial";
			case PCIClass.Communication.Modem: return "Modem";
			case PCIClass.Communication.Other: return "Other Comm";

			case PCIClass.System.PIC: return "PIC";
			case PCIClass.System.IOAPIC: return "IOAPIC";
			case PCIClass.System.IOXAPIC: return "IOXAPIC";
			case PCIClass.System.DMA: return "DMA";
			case PCIClass.System.Timer: return "Timer";
			case PCIClass.System.RTC: return "RTC";
			case PCIClass.System.Hotplug: return "PCI Hotplug";
			case PCIClass.System.SDHCI: return "SDHCI";
			case PCIClass.System.Other: return "Other System";

			case PCIClass.Input.Keyboard: return "Keyboard";
			case PCIClass.Input.Pen: return "Pen";
			case PCIClass.Input.Mouse: return "Mouse";
			case PCIClass.Input.Scanner: return "SCANNER";
			case PCIClass.Input.Gameport: return "Gameport";
			case PCIClass.Input.Other: return "Other Input";

			case PCIClass.Docking.Generic: return "Docking generic";
			case PCIClass.Docking.Other: return "Docking Other";

			case PCIClass.Processor.I386: return "i386";
			case PCIClass.Processor.I486: return "i486";
			case PCIClass.Processor.Pentium: return "Pentium";
			case PCIClass.Processor.Alpha: return "Alpha";
			case PCIClass.Processor.MIPS: return "MIPS";
			case PCIClass.Processor.CO: return "CO???";

			case PCIClass.Serial.FW: return "Firewire";
			case PCIClass.Serial.FW_OHCI: return "Firewire-OHCI";
			case PCIClass.Serial.SSA: return "SSA";
			case PCIClass.Serial.USB: return "USB";
			case PCIClass.Serial.USB_UHCI: return "USB UHCI";
			case PCIClass.Serial.USB_OHCI: return "USB OHCI";
			case PCIClass.Serial.USB_EHCI: return "USB EHCI";
			case PCIClass.Serial.Fiber: return "Fiber";
			case PCIClass.Serial.SMBus: return "SMBUS";

			case PCIClass.Wireless.RF_CTRL: return "Wireless rf control";
			case PCIClass.Wireless.WHCI: return "Wireless rf control";

			case PCIClass.Intelligent.I20: return "Intelligent I2O";

			case PCIClass.Satellite.TV: return "Satellite Tv";
			case PCIClass.Satellite.Audio: return "Satellite Audio";
			case PCIClass.Satellite.Voice: return "Satellite Voice";
			case PCIClass.Satellite.Data: return "Satellite Data";

			case PCIClass.Crypt.Network: return "Crypt Network";
			case PCIClass.Crypt.Entertaim: return "Crypt Entertainment";
			case PCIClass.Crypt.Other: return "Crypt Other";

			case PCIClass.SignalProcessing.DPIO: return "DPIO";
			case PCIClass.SignalProcessing.Other: return "DSP Other";
			default: return "Invalid class subclass";
		}
	}


static:
	@property bool IsPresent() { return Port.Read!uint(DataRegister) != 0xFFFFFFFF; }


	void ScanDevices() {
		if (!IsPresent)
			return;

		auto pf = new PCIDev(0, 0, 0, cast(Common)0);
		foreach (ubyte bus; 0 .. 4) {
			foreach (ubyte dev; 0 .. 32) {
				foreach (ubyte func; 0 .. 8) {
					pf.bus = bus;
					pf.dev = dev;
					pf.func = func;

					uint tmp[4];
					foreach (uint i, ref x; tmp)
						x = pf.Read!uint(i << 2);

					auto cfg = cast(Common *)tmp.ptr;
					if (cfg.VendorID == 0xFFFF || !cfg.VendorID)
						continue;

					auto newDev = new PCIDev(bus, dev, func, *cfg);
					foreach (uint i, ref x; newDev.devi)
						x = newDev.Read!uint((i << 2) + 16);

					Log.PrintSP("\nPCI: " ~ 
						Convert.ToString(newDev.bus) ~ " " ~
						Convert.ToString(newDev.dev) ~ " " ~
						Convert.ToString(newDev.func) ~ " " ~
						newDev.ClassName ~ " | "  ~
						newDev.VendorDevice ~ " | " ~ 
						newDev.Vendor);
				}
			}
		}
	}
}