module Drivers.Power.ACPI;

import Architectures;
import MemoryManager;

import System.Collections;


class ACPI {
static:
public:
	bool FindTable() {
		if (!FindRSDP())
			return false;

		if (!IsChecksumValid(cast(ubyte *)ptrRSDP, 20))
			return false;

		if (!isLegacyRSDP) {
			if (!IsChecksumValid(cast(ubyte *)ptrRSDP, ptrRSDP.Length))
				return false;
		}
		
		return true;
	}

	bool ReadTable() {
		bool a = ptrRSDP.Revision && ptrRSDP.ptrXSDT;
		ptrHeader = cast(ACPIHeader *)Paging.KernelPaging.MapRegion(cast(PhysicalAddress)(a ? ptrRSDP.ptrXSDT : ptrRSDP.ptrRSDT), ACPIHeader.sizeof);

		if (!Validate(ptrHeader, (a ? "XSDT" : "RSDT")))
			return false;

		if (ptrHeader !is null)
			FindDescriptors(ptrHeader);

		if (ptrMADT is null)
			return false;

		if (!InitializeRedirectionEntries())
			return false;

		if (ptrHPET)
			ReadHPET();

		ReadMADT();
		return true;
	}


private:
	enum maxEntries = 256;

	__gshared bool isLegacyRSDP;
	__gshared RSDP* ptrRSDP;
	__gshared MADT* ptrMADT;

	__gshared ACPIHeader* ptrHeader;
	__gshared HeaderHPET* ptrHPET;

	
	bool FindRSDP() {
		if (Scan(cast(ubyte *)0xE0000 + cast(ulong)Memory.VirtualStart, cast(ubyte *)0xFFFFF + cast(ulong)Memory.VirtualStart))
			return true;

		foreach(region; Memory.RegionInfo[0 .. Memory.NumRegions])
			if (region.Type == RegionType.Reserved)
				if (Scan(region.VirtualStart, region.VirtualStart + region.Length))
					return true;

		return false;
	}

	bool Scan(ubyte* start, ubyte* end) {
		for(ubyte* currentByte = start; currentByte < end - 8; currentByte += 16) {
			if (currentByte[0 .. 8] == "RSD PTR ") {
				ptrRSDP = cast(RSDP *)currentByte;
				isLegacyRSDP = (ptrRSDP.Revision == 0);
				return true;
			}
		}

		return false;
	}

	bool Validate(ACPIHeader* ptr, string str) {
		if (!IsChecksumValid(cast(ubyte *)ptr, ptr.Length))
			return false;

		if (ptr.Signature[0 .. 4] == str)
			return true;

		return false;
	}
	
	void FindDescriptors(ACPIHeader* ptr) {
		uint* endByte = cast(uint *)((cast(ubyte *)ptr) + ptr.Length);
		uint* curByte = cast(uint *)(ptr + 1);
		
		for (; curByte < endByte; curByte++) {
			DescriptorHeader* curTable = cast(DescriptorHeader *)Paging.KernelPaging.MapRegion(cast(PhysicalAddress)(*curByte), MADT.sizeof);
			
			if (curTable.Signature[0 .. 4] == "APIC")
				ptrMADT = cast(MADT *)curTable;
			else if (curTable.Signature[0 .. 4] == "HPET")
				ptrHPET = cast(HeaderHPET *)curTable;
		}
	}

	
	struct DescriptorHeader {
	align(1):
		char[4] Signature;
		uint Length;
	}

	struct RSDP {
	align(1):
		char[8] Signature;
		ubyte Checksum;
		ubyte[6] OEMID;
		ubyte Revision;
		uint ptrRSDT;
		uint Length;
		ulong ptrXSDT;
		ubyte extChecksum;
		ubyte[3] reserved;
	}

	struct MADT {
	align(1):
		ACPIHeader Header;
		uint LocalAPICAddr;
		
		uint Flags;
	}

	struct ACPIHeader {
	align(1):
		char[4] Signature;
		uint Length;
		
		ubyte Revision;
		ubyte Checksum;
		ubyte[6] OEMID;
		
		ulong OEMTableID;
		uint OEMRevision;
		uint CreatorID;
		uint CreatorRevision;
	}

	struct ACPIAddressFormat {
	align(1):
		ubyte AddressSpaceID;
		ubyte RegisterBitWidth;
		ubyte RegisterBitOffset;
		private ubyte reserved;
		ulong Address;
	}

	struct HeaderHPET {
	align(1):
		ACPIHeader Header;
		uint EventTimerBlockID;
		ACPIAddressFormat BaseAddress;
		ubyte HPETNumber;
		ushort MinTickInPeriodicMode;
		ubyte Attribute;
	}

	struct EntryLocalAPIC {
	align(1):
		ubyte Type;
		ubyte Length;
		ubyte ACPICPUID;
		ubyte APICID;
		uint Flags;
	}

	struct EntryIOAPIC {
	align(1):
		ubyte Type;
		ubyte Length;

		ubyte IOAPICID;
		ubyte Reserved;

		uint IOAPICAddr;
		uint GlobalSystemInterruptBase;
	}

	struct EntryInterruptSourceOverride {
	align(1):
		ubyte Type;
		ubyte Length;
		ubyte Bus;
		ubyte Source;

		uint GlobalSystemInterrupt;
		private ushort Flags;

		mixin(Bitfield!(Flags, "po", 2, "el", 2, "reserved", 12));
	}

	struct EntryNMISource {
	align(1):
		ubyte Type;
		ubyte Length;
		private ushort Flags;

		uint GlobalSystemInterrupt;

		mixin(Bitfield!(Flags, "po", 2, "el", 2, "reserved", 12));
	}

	struct EntryLocalAPICNMI {
	align(1):
		ubyte Type;
		ubyte Length;
		
		ubyte ACPICPUID;
		private ushort Flags;
		ubyte LocalAPICLINT;

		mixin(Bitfield!(Flags, "polarity", 2, "trigger", 2, "reserved", 12));
	}

	struct EntryLocalAPICAddressOverrideStructure {
	align(1):
		ubyte Type;
		ubyte Length;
		private ushort reserved;
		ulong LocalAPICAddr;
	}

	struct EntryIOSAPIC {
	align(1):
		ubyte Type;
		ubyte Length;
		ubyte IOAPICID;
		ubyte reserved;

		uint GlobalSystemInterruptBase;
		ulong IOSAPICAddr;
	}

	struct EntryLocalSAPIC {
	align(1):
		ubyte Type;
		ubyte Length;
		ubyte ACPICPUID;
		ubyte LocalSAPICID;
		ubyte LocalSAPICEID;
		private ubyte[3] reserved;
		uint Flags;
		uint ACPICPUUID;
	}
	
	
	bool InitializeRedirectionEntries() {
		Info.NumEntries = 16;
		for (ubyte i = 0; i < 16; i++) {
			Info.RedirectionEntries[i].destination = 0xff;
			Info.RedirectionEntries[i].interruptType = Info.InterruptType.Masked;
			Info.RedirectionEntries[i].triggerMode = Info.TriggerMode.EdgeTriggered;
			Info.RedirectionEntries[i].inputPinPolarity = Info.InputPinPolarity.HighActive;
			Info.RedirectionEntries[i].destinationMode = Info.DestinationMode.Logical;
			Info.RedirectionEntries[i].deliveryMode = Info.DeliveryMode.LowestPriority;
			Info.RedirectionEntries[i].sourceBusIRQ = i;
			Info.RedirectionEntries[i].vector = cast(ubyte)(i + 32);
		}
		return true;
	}

	void ReadHPET() {
		//import Core, System;
		//Log.Print(" add: " ~ Convert.ToString(ptrHPET));
	}
	
	void ReadMADT() {
		ubyte* curByte = (cast(ubyte *)ptrMADT) + MADT.sizeof - 4;
		ubyte* endByte = curByte + (ptrMADT.Header.Length - MADT.sizeof);
		endByte--;
		
		Info.LocalAPICAddress = cast(PhysicalAddress)ptrMADT.LocalAPICAddr;
		while(curByte < endByte) {
			switch(*curByte) {
				case 0: // Local APIC entry
					auto lapicInfo = cast(EntryLocalAPIC *)curByte;
					Info.LAPICs[Info.NumLAPICs].ID = lapicInfo.APICID;
					Info.LAPICs[Info.NumLAPICs].Ver = 0;
					Info.LAPICs[Info.NumLAPICs].Enabled = (lapicInfo.Flags & 0x1) == 0x1;
					Info.NumLAPICs++;
					break;

				case 1: // IO APIC entry
					auto ioapicInfo = cast(EntryIOAPIC *)curByte;
					Info.IOAPICs[Info.NumIOAPICs].ID = ioapicInfo.IOAPICID;
					Info.IOAPICs[Info.NumIOAPICs].Ver = 0;
					Info.IOAPICs[Info.NumIOAPICs].Enabled = true;
					Info.IOAPICs[Info.NumIOAPICs].Address = cast(PhysicalAddress)ioapicInfo.IOAPICAddr;
					Info.NumIOAPICs++;
					break;

				case 2: // Interrupt Source Overrides
					auto nmiInfo = cast(EntryInterruptSourceOverride *)curByte;
					Info.RedirectionEntries[nmiInfo.GlobalSystemInterrupt].deliveryMode = Info.DeliveryMode.SystemManagementInterrupt;

					switch (nmiInfo.el) {
						default:
						case 0:
						case 1:
							Info.RedirectionEntries[nmiInfo.GlobalSystemInterrupt].triggerMode = Info.TriggerMode.EdgeTriggered;
							break;
						case 2:
							Info.RedirectionEntries[nmiInfo.GlobalSystemInterrupt].triggerMode = Info.TriggerMode.LevelTriggered;
							break;
					}

					switch (nmiInfo.po) {
						default:
						case 0:
						case 1:
							Info.RedirectionEntries[nmiInfo.GlobalSystemInterrupt].inputPinPolarity = Info.InputPinPolarity.HighActive;
							break;
						case 2:
							Info.RedirectionEntries[nmiInfo.GlobalSystemInterrupt].inputPinPolarity = Info.InputPinPolarity.LowActive;
							break;
					}
					break;

				case 3: // NMI sources
					auto nmiInfo = cast(EntryNMISource *)curByte;
					Info.RedirectionEntries[nmiInfo.GlobalSystemInterrupt].deliveryMode = Info.DeliveryMode.NonMaskedInterrupt;

					switch (nmiInfo.el) {
						default:
						case 0:
						case 1:
							Info.RedirectionEntries[nmiInfo.GlobalSystemInterrupt].triggerMode = Info.TriggerMode.EdgeTriggered;
							break;
						case 2:
							Info.RedirectionEntries[nmiInfo.GlobalSystemInterrupt].triggerMode = Info.TriggerMode.LevelTriggered;
							break;
					}

					switch (nmiInfo.po) {
						default:
						case 0:
						case 1:
							Info.RedirectionEntries[nmiInfo.GlobalSystemInterrupt].inputPinPolarity = Info.InputPinPolarity.HighActive;
							break;
						case 2:
							Info.RedirectionEntries[nmiInfo.GlobalSystemInterrupt].inputPinPolarity = Info.InputPinPolarity.LowActive;
							break;
					}

					break;

				case 4: // LINTn Sources (Local APIC NMI Sources)
					auto nmiInfo = cast(EntryLocalAPICNMI *)curByte; 
					break;

				default:
					break;
			}

			curByte++;
			curByte += (*curByte) - 1;
		}
	}

	bool IsChecksumValid(ubyte* startAddr, uint length) {
		ubyte* endAddr = startAddr + length;
		int acc = 0;

		for (; startAddr < endAddr; startAddr++)
			acc += *startAddr;

		return (acc & 0xFF) == 0;
	}
}
