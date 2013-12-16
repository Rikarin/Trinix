module Drivers.Power.MP;

import MemoryManager;
import Architectures;
import System.Collections;


class MP {
public:
static:
	bool FindTable() {
		ulong[] checkStart = [0xF0000, 0x9FC00];
		ulong[] checkLen = [0xFFFF, 0x400];

		foreach (i, val; checkStart) {
			MPFloatingPointer* tmp;
			val += cast(ulong)Memory.VirtualStart;
			
			tmp = Scan(cast(ubyte *)val, cast(ubyte *)(val + checkLen[i]));
			if (tmp !is null) {
				mpFloating = tmp;
				return true;
			}
		}
		return false;
	}

	bool ReadTable() {
		if (!mpFloating.mpFeatures1) {
			mpConfig = cast(MPConfigurationTable*)(cast(ulong)mpFloating.mpConfigPointer);
			mpConfig = cast(MPConfigurationTable*)(cast(ubyte *)mpConfig + cast(ulong)Memory.VirtualStart);

			if (!IsChecksumValid(cast(ubyte *)mpConfig, mpConfig.BaseTableLength))
				return false;
		} else
			return false;


		return false;

/*
		Info.LocalAPICAddress = cast(PhysicalAddress)mpConfig.AddressOfLocalAPIC;

		ubyte* curAddr = cast(ubyte*)mpConfig;
		curAddr += MPConfigurationTable.sizeof;

		uint lastState = 0;

		for (uint i = 0; i < mpConfig.entryCount; i++) {
			lastState = *curAddr;

			switch(lastState) {
				case 0:
					// Set the Processor Entry in the Info struct
					ProcessorEntry* processor = cast(ProcessorEntry*)curAddr;

					Info.LAPICs[Info.numLAPICs].ID = processor.localAPICID;
					Info.LAPICs[Info.numLAPICs].ver = processor.localAPICVersion;
					Info.LAPICs[Info.numLAPICs].enabled = cast(bool)processor.cpuEnabledBit;

					// increment the count
					Info.numLAPICs++;

					curAddr += ProcessorEntry.sizeof;
					break;

				case 1: // Bus Entry

					curAddr += BusEntry.sizeof;
					break;

				case 2: // IO APIC Entry

					IOAPICEntry* ioapic = cast(IOAPICEntry*)curAddr;

					Info.IOAPICs[Info.numIOAPICs].ID = ioapic.ioAPICID;
					Info.IOAPICs[Info.numIOAPICs].ver = ioapic.ioAPICVersion;
					Info.IOAPICs[Info.numIOAPICs].enabled = cast(bool)ioapic.ioAPICEnabled;
					Info.IOAPICs[Info.numIOAPICs].address = cast(PhysicalAddress)ioapic.ioAPICAddress;

					// increment the count
					Info.numIOAPICs++;

					curAddr += IOAPICEntry.sizeof;
					break;

				case 3: // IO Interrupt Entry

					IOInterruptEntry* ioentry = cast(IOInterruptEntry*)curAddr;
					Info.redirectionEntries[Info.numEntries].sourceBusIRQ = ioentry.sourceBusIRQ;
					Info.redirectionEntries[Info.numEntries].vector = ioentry.destinationIOAPICIntin + 32;

					switch (ioentry.po)
					{
						case 0:
							// Conforms to the bus (dumb)
						case 1:
							// Active High
							Info.redirectionEntries[Info.numEntries].inputPinPolarity = Info.InputPinPolarity.HighActive;
							break;
						case 3:
							// Active Low
							Info.redirectionEntries[Info.numEntries].inputPinPolarity = Info.InputPinPolarity.LowActive;
							break;
						default:
							// undefined
							break;
					}

					switch (ioentry.el) {
						case 0:
							// Conforms to the bus (dumb!)
						case 1:
							// Edge-Triggered
							Info.redirectionEntries[Info.numEntries].triggerMode = Info.TriggerMode.EdgeTriggered;
							break;
						case 3:
							// Level-Triggered
							Info.redirectionEntries[Info.numEntries].triggerMode = Info.TriggerMode.LevelTriggered;
							break;
						default:
							// undefined
							break;
					}

					// XXX: switch(ioentry.interruptType) will cause a relocation error
					ulong intType = ioentry.interruptType;
					switch (intType)
					{
						case 0: // It is an INT (common)
							Info.redirectionEntries[Info.numEntries].deliveryMode = Info.DeliveryMode.LowestPriority;
							break;
						case 1: // It is a NMI
							Info.redirectionEntries[Info.numEntries].deliveryMode = Info.DeliveryMode.NonMaskedInterrupt;
							break;
						case 2: // It is a SMI
							Info.redirectionEntries[Info.numEntries].deliveryMode = Info.DeliveryMode.SystemManagementInterrupt;
							break;
						case 3: // It is an external interrupt (devices, etc)
							Info.redirectionEntries[Info.numEntries].deliveryMode = Info.DeliveryMode.ExtINT;
							break;
					}

					Info.numEntries++;

					curAddr += IOInterruptEntry.sizeof;
					break;

				case 4: // Local Interrupt Entry (LAPIC LIVT)

					curAddr += LocalInterruptEntry.sizeof;
					break;

				case 128: // System Address Space Mapping

					curAddr += SystemAddressSpaceMappingEntry.sizeof;
					break;

				case 129: // Bus Hierarchy Descriptor Entry

					curAddr += BusHierarchyDescriptorEntry.sizeof;
					break;

				case 130:

					curAddr += CompatibilityBusAddressSpaceModifierEntry.sizeof;
					break;

				default:

					// WTF

					// Unknown Entry type

					break;

			}
		}*/
	}


private:
	__gshared MPFloatingPointer* mpFloating;
	__gshared MPConfigurationTable* mpConfig;

	struct MPFloatingPointer {
	align(1):
		uint Signature;
		uint mpConfigPointer;
		ubyte Length;
		ubyte mpVersion;
		ubyte Checksum;
		ubyte mpFeatures1;
		ubyte mpFeatures2;
		ubyte mpFeatures3;
		ubyte mpFeatures4;
		ubyte mpFeatures5;
	}

	struct MPConfigurationTable {
	align(1):
		uint Signature;
		ushort BaseTableLength;
		ubyte Revision;
		ubyte Checksum;
		char[8] oemID;
		char[12] ProductID;
		uint oemTablePointer;
		ushort oemTableSize;
		ushort EntryCount;
		uint AddressOfLocalAPIC;
		ushort ExtendedTableLength;
		ubyte ExtendedTableChecksum;
		ubyte Reserved;
	}

	struct ProcessorEntry {
	align(1):
		ubyte EntryType;
		ubyte LocalAPICID;
		ubyte LocalAPICVersion;
		ubyte cpuFlags;
		uint cpuSignature;
		uint cpuFeatureFlags;
		ulong Reserved;

		mixin(Bitfield!(cpuFlags, "cpuEnabledBit", 1, "cpuBootstrapProcessorBit", 1, "reserved2", 6));
	}

	struct BusEntry {
	align(1):
		ubyte EntryType;
		ubyte BusID;
		char[6] BusTypeString;
	}

	struct IOAPICEntry {
	align(1):
		ubyte EntryType;
		ubyte ioAPICID;
		ubyte ioAPICVersion;
		ubyte ioAPICEnabledByte;
		uint ioAPICAddress;

		mixin(Bitfield!(ioAPICEnabledByte, "ioAPICEnabled", 1, "reserved", 7));
	}

	struct IOInterruptEntry {
	align(1):
		ubyte EntryType;
		ubyte InterruptType;
		ubyte ioInterruptFlags;
		ubyte reserved;
		ubyte SourceBusID;
		ubyte SourceBusIRQ;
		ubyte DestinationIOAPICID;
		ubyte DestinationIOAPICIntin;

		mixin(Bitfield!(ioInterruptFlags, "po", 2, "el", 2, "reserved2", 4));
	}

// -- Extended MP Configuration Table Entries -- //
	struct SystemAddressSpaceMappingEntry {
	align(1):
		ubyte EntryType;
		ubyte EntryLength;
		ubyte BusID;
		ubyte AddressType;
		ulong AddressBase;
		ulong AddressLength;
	}

	struct BusHierarchyDescriptorEntry {
	align(1):
		ubyte EntryType;
		ubyte EntryLength;
		ubyte BusID;
		ubyte BusInformation;
		ubyte ParentBus;
		ubyte[3] reserved;

		mixin(Bitfield!(BusInformation, "sd", 1, "reserved2", 7));
	}

	struct CompatibilityBusAddressSpaceModifierEntry {
	align(1):
		ubyte EntryType;
		ubyte EntryLength;
		ubyte BusID;
		ubyte AddressModifier;
		uint PredefinedRangeList;

		mixin(Bitfield!(AddressModifier, "pr", 1, "reserved", 7));
	}


	MPFloatingPointer* Scan(ubyte* start, ubyte* end) {
		for (ubyte* currentByte = start; currentByte < end - 3; currentByte++) {
			if (*(cast(uint *)currentByte) == *(cast(uint *)("_MP_"c.ptr))) {
				MPFloatingPointer* floatingTable = cast(MPFloatingPointer *)currentByte;

				if (floatingTable.Length == 0x1
					&& floatingTable.mpVersion == 0x4
					&& IsChecksumValid(currentByte, MPFloatingPointer.sizeof))
					return floatingTable;
			}
		}

		return null;
	}

	bool IsChecksumValid(ubyte* startAddr, uint length) {
		ubyte* endAddr = startAddr + length;
		int acc;
		for (; startAddr < endAddr; startAddr++)
			acc += *startAddr;

		return ((acc &= 0xff) == 0);
	}
}
