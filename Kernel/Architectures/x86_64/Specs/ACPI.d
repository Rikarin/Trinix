module Architectures.x86_64.Specs.ACPI;

import System.Collections.All;
import MemoryManager.Memory;

import Architectures.Paging;
import Architectures.x86_64.Core.Info;


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
		ptrXSDT = null;
		ptrRSDT = null;

		if (ptrRSDP.Revision >= 1 && ptrRSDP.ptrXSDT) {
			ptrXSDT = cast(XSDT *)Paging.KernelPaging.MapRegion(cast(PhysicalAddress)ptrRSDP.ptrXSDT, RSDT.sizeof);
			
			if (!ValidateXSDT())
				return false;
		} else {
			ptrRSDT = cast(RSDT *)Paging.KernelPaging.MapRegion(cast(PhysicalAddress)ptrRSDP.ptrRSDT, RSDT.sizeof);

			if (!ValidateRSDT())
				return false;
		}

		if (ptrXSDT !is null)
			FindDescriptors();
		else
			FindDescriptors32();

		if (ptrMADT is null)
			return false;

		if (!InitializeRedirectionEntries())
			return false;

		ReadMADT();
		return true;
	}


private:
	const uint maxEntries = 256;

	__gshared bool isLegacyRSDP;
	__gshared RSDP* ptrRSDP;
	__gshared RSDT* ptrRSDT;
	__gshared XSDT* ptrXSDT;
	__gshared MADT* ptrMADT;

	struct acpiMPBase {
		EntryLocalAPIC*[maxEntries] LocalAPICs;
		uint NumLocalAPICs;

		EntryIOAPIC*[maxEntries] IOAPICs;
		uint NumIOAPICs;

		EntryInterruptSourceOverride*[maxEntries] IntSources;
		uint NumIntSources;

		EntryNMISource*[maxEntries] NMISources;
		uint NumNMISources;

		EntryLocalAPICNMI*[maxEntries] LocalAPICNMIs;
		uint MumLocalAPICNMIs;
	}

	
	bool FindRSDP() {
		if (Scan(cast(ubyte *)0xE0000 + cast(ulong)Memory.VirtualStart, cast(ubyte *)0xFFFFF + cast(ulong)Memory.VirtualStart))
			return true;

		foreach(region; Memory.RegionInfo)
			if (region.Type == RegionType.Reserved)
				if (Scan(region.VirtualStart, region.VirtualStart + region.Length))
					return true;

		return false;
	}

	bool Scan(ubyte* start, ubyte* end) {
		ubyte* currentByte = start;
		for(; currentByte < end - 8; currentByte += 16) {
			if (cast(char)*(currentByte + 0) == 'R' &&
					cast(char)*(currentByte + 1) == 'S' &&
					cast(char)*(currentByte + 2) == 'D' &&
					cast(char)*(currentByte + 3) == ' ' &&
					cast(char)*(currentByte + 4) == 'P' &&
					cast(char)*(currentByte + 5) == 'T' &&
					cast(char)*(currentByte + 6) == 'R' &&
					cast(char)*(currentByte + 7) == ' ') {
				ptrRSDP = cast(RSDP *)currentByte;
				isLegacyRSDP = (ptrRSDP.Revision == 0);
				return true;
			}
		}

		return false;
	}

	bool ValidateRSDT() {
		if (!IsChecksumValid(cast(ubyte *)ptrRSDT, ptrRSDT.Length))
			return false;

		if (ptrRSDT.Signature[0] == 'R' &&
				ptrRSDT.Signature[1] == 'S' &&
				ptrRSDT.Signature[2] == 'D' &&
				ptrRSDT.Signature[3] == 'T') {
			return true;
		}

		return false;
	}

	bool ValidateXSDT() {
		if (!IsChecksumValid(cast(ubyte *)ptrXSDT, ptrXSDT.Length))
			return false;

		if (ptrXSDT.Signature[0] == 'X' &&
				ptrXSDT.Signature[1] == 'S' &&
				ptrXSDT.Signature[2] == 'D' &&
				ptrXSDT.Signature[3] == 'T') {
			return true;
		}

		return false;
	}
	
	void FindDescriptors32() {
		uint* endByte = cast(uint *)((cast(ubyte *)ptrRSDT) + ptrRSDT.Length);
		uint* curByte = cast(uint *)(ptrRSDT + 1);
		
		for (; curByte < endByte; curByte++) {
			DescriptorHeader* curTable = cast(DescriptorHeader *)Paging.KernelPaging.MapRegion(cast(PhysicalAddress)(*curByte), MADT.sizeof);
			
			if (curTable.Signature[0] == 'A' &&
					curTable.Signature[1] == 'P' &&
					curTable.Signature[2] == 'I' &&
					curTable.Signature[3] == 'C')
				ptrMADT = cast(MADT *)(cast(ubyte *)curTable);
		}
	}

	void FindDescriptors() {
		ulong* endByte = cast(ulong *)((cast(ubyte *)ptrXSDT) + ptrXSDT.Length);
		ulong* curByte = cast(ulong *)(ptrXSDT + 1);

		for (; curByte < endByte; curByte++) {
			DescriptorHeader* curTable = cast(DescriptorHeader*)((*curByte) + cast(ulong)Memory.VirtualStart);

			if (curTable.Signature[0] == 'A' &&
					curTable.Signature[1] == 'P' &&
					curTable.Signature[2] == 'I' &&
					curTable.Signature[3] == 'C') {
				ptrMADT = cast(MADT*)curTable;
			}
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

	struct RSDT {
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

	struct XSDT {
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

	struct MADT {
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
		uint LocalAPICAddr;
		
		uint Flags;
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
		ushort Flags;

		mixin(Bitfield!(Flags, "po", 2, "el", 2, "reserved", 12));
	}

	struct EntryNMISource {
	align(1):
		ubyte Type;
		ubyte Length;
		ushort Flags;

		uint GlobalSystemInterrupt;

		mixin(Bitfield!(Flags, "po", 2, "el", 2, "reserved", 12));
	}

	struct EntryLocalAPICNMI {
	align(1):
		ubyte Type;
		ubyte Length;
		
		ubyte ACPICPUID;
		ushort Flags;
		ubyte LocalAPICLINT;

		mixin(Bitfield!(Flags, "polarity", 2, "trigger", 2, "reserved", 12));
	}

	struct EntryLocalAPICAddressOverrideStructure {
	align(1):
		ubyte Type;
		ubyte Length;
		ushort reserved;
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
		ubyte[3] reserved;
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
	
	void ReadMADT() {
		ubyte* curByte = (cast(ubyte *)ptrMADT) + MADT.sizeof;
		ubyte* endByte = curByte + (ptrMADT.Length - MADT.sizeof);
		endByte--;

		curByte -= 4; //qemu bug?!?
		
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

				case 1:  // IO APIC entry
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
