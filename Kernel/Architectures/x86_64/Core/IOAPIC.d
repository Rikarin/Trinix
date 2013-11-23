module Architectures.x86_64.Core.IOAPIC;

import MemoryManager;
import Architectures;


class IOAPIC {
public:
static:
	bool Init() {
		pinToIOAPIC[] = 0;
		irqToIOAPIC[] = 0;
		numPins = 0;

		PIC.Disable();

		for(int i = 0; i < Info.NumIOAPICs; i++)
			InitUnit(Info.IOAPICs[i].ID, Info.IOAPICs[i].Address, false);

		SetRedirectionTableEntries();
		return true;
	}

	bool UnmaskIRQ(uint irq, uint core) {
		if (irq > 15)
			return false;

		UnmaskRedirectionTableEntry(irqToIOAPIC[irq], irqToPin[irq]);
		return true;
	}

	bool MaskIRQ(uint irq) {
		if (irq > 15)
			return false;

		MaskRedirectionTableEntry(irqToIOAPIC[irq], irqToPin[irq]);
		return true;
	}

	bool UnmaskPin(uint pin) {
		if (pin >= numPins)
			return false;

		uint IOAPICID = pinToIOAPIC[pin];
		uint IOAPICPin = pin - ioApicStartingPin[IOAPICID];

		UnmaskRedirectionTableEntry(IOAPICID, IOAPICPin);
		return true;
	}

	bool MaskPin(uint pin) {
		if (pin >= numPins)
			return false;

		uint IOAPICID = pinToIOAPIC[pin];
		uint IOAPICPin = pin - ioApicStartingPin[IOAPICID];

		MaskRedirectionTableEntry(IOAPICID, IOAPICPin);
		return true;
	}


private:
	__gshared uint irqToPin[16] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
	__gshared uint irqToIOAPIC[16];
	__gshared uint pinToIOAPIC[256];
	__gshared uint numPins;

	__gshared uint* ioApicRegisterSelect[16];
	__gshared uint* ioApicWindowRegister[16];
	__gshared uint ioApicStartingPin[16];

	enum Register {
		ID,
		VER,
		ARB,
		REDTBL0LO = 0x10,
		REDTBL0HI
	}


	void InitUnit(ubyte ioAPICID, PhysicalAddress ioAPICAddress, bool hasIMCR) {
		if (hasIMCR) {
			Port.Write!byte(0x22, 0x70);
			Port.Write!byte(0x23, 0x01);
		}

		ubyte* IOAPICVirtAddr = Paging.KernelPaging.MapRegion(ioAPICAddress, 0x1000).ptr;

		ioApicRegisterSelect[ioAPICID] = cast(uint *)(IOAPICVirtAddr);
		ioApicWindowRegister[ioAPICID] = cast(uint *)(IOAPICVirtAddr + 0x10);

		ubyte apicVersion, maxRedirectionEntry;
		GetIOApicVersion(ioAPICID, apicVersion, maxRedirectionEntry);
		maxRedirectionEntry++;

		ioApicStartingPin[ioAPICID] = numPins;
		for(int i = 0; i < maxRedirectionEntry; i++)
			pinToIOAPIC[i + numPins] = ioAPICID;
		numPins += maxRedirectionEntry;
	}

	uint ReadRegister(uint ioApicID, Register reg) {
		uint* ptr = ioApicRegisterSelect[ioApicID];
		*ptr = cast(uint)reg;

		return *(ioApicWindowRegister[ioApicID]);
	}

	void WriteRegister(uint ioApicID, Register reg, in uint value) {
		*(ioApicRegisterSelect[ioApicID]) = cast(uint)reg;
		*(ioApicWindowRegister[ioApicID]) = value;
	}

	ubyte GetID(uint ioApicID) {
		uint value = ReadRegister(ioApicID, Register.ID);
		value >>= 24;
		value &= 0xF;

		return cast(ubyte)value;
	}

	void SetID(uint ioApicID, ubyte apicID) {
		uint value = cast(uint)apicID << 24;
		WriteRegister(ioApicID, Register.ID, value);
	}

	void GetIOApicVersion(uint ioApicID, out ubyte apicVersion, out ubyte maxRedirectionEntry) {
		uint value = ReadRegister(ioApicID, Register.VER);

		apicVersion = (value & 0xFF);
		value >>= 16;

		maxRedirectionEntry = (value & 0xFF);
	}

	void SetRedirectionTableEntry(uint ioApicID, uint registerIndex, ubyte destinationField,
			Info.InterruptType intType, Info.TriggerMode triggerMode, Info.InputPinPolarity inputPinPolarity,
			Info.DestinationMode destinationMode, Info.DeliveryMode deliveryMode, ubyte interruptVector) {

		int valuehi = destinationField;
		valuehi <<= 24;

		int valuelo = intType;

		valuelo <<= 1;
		valuelo |= triggerMode;

		valuelo <<= 2;
		valuelo |= inputPinPolarity;

		valuelo <<= 2;
		valuelo |= destinationMode;

		valuelo <<= 3;
		valuelo |= deliveryMode;

		valuelo <<= 8;
		valuelo |= interruptVector;

		valuelo |= (1 << 16);

		WriteRegister(ioApicID, cast(Register)(Register.REDTBL0HI + (registerIndex * 2)), valuehi);
		WriteRegister(ioApicID, cast(Register)(Register.REDTBL0LO + (registerIndex * 2)), valuelo);

	}

	void SetRedirectionTableEntries() {
		for (int i = 0; i < Info.NumEntries && i < numPins; i++) {
			int IOAPICID = pinToIOAPIC[i];
			int IOAPICPin = i - ioApicStartingPin[IOAPICID];

			SetRedirectionTableEntry(IOAPICID, IOAPICPin,
				Info.RedirectionEntries[i].destination,
				Info.RedirectionEntries[i].interruptType,
				Info.RedirectionEntries[i].triggerMode,
				Info.RedirectionEntries[i].inputPinPolarity,
				Info.RedirectionEntries[i].destinationMode,
				Info.RedirectionEntries[i].deliveryMode,
				Info.RedirectionEntries[i].vector);

			if (Info.RedirectionEntries[i].sourceBusIRQ < 16) {
				irqToPin[Info.RedirectionEntries[i].sourceBusIRQ] = i;
				irqToIOAPIC[Info.RedirectionEntries[i].sourceBusIRQ] = IOAPICID;
			}
		}
	}

	void UnmaskRedirectionTableEntry(uint ioApicID, uint registerIndex) {
		uint lo = ReadRegister(ioApicID, cast(Register)(Register.REDTBL0LO + (registerIndex * 2)));
		lo &= ~(1 << 16);

		WriteRegister(ioApicID, cast(Register)(Register.REDTBL0LO + (registerIndex * 2)), lo);
	}

	void MaskRedirectionTableEntry(uint ioApicID, uint registerIndex) {
		uint lo = ReadRegister(ioApicID, cast(Register)(Register.REDTBL0LO + (registerIndex * 2)));
		lo |= (1 << 16);

		WriteRegister(ioApicID, cast(Register)(Register.REDTBL0LO + (registerIndex * 2)), lo);
	}
}
