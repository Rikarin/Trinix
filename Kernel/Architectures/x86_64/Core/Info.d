module Architectures.x86_64.Core.Info;

import MemoryManager;


struct Info {
public:
static:
	enum DestinationMode {
		Physical,
		Logical
	}

	enum InputPinPolarity {
		HighActive,
		LowActive
	}

	enum TriggerMode {
		EdgeTriggered,
		LevelTriggered
	}

	enum InterruptType {
		Unmasked,
		Masked
	}

	enum DeliveryMode {
		Fixed,
		LowestPriority,
		SystemManagementInterrupt,
		NonMaskedInterrupt = 0x4,
		INIT,
		ExtINT = 0x7
	}

	struct RedirectionEntry {
		ubyte destination = 0xFF;
		InterruptType interruptType;
		TriggerMode triggerMode;
		InputPinPolarity inputPinPolarity;
		DestinationMode destinationMode = DestinationMode.Logical;
		DeliveryMode deliveryMode;
		ubyte vector;
		ubyte sourceBusIRQ;
	}

	__gshared RedirectionEntry[256] RedirectionEntries;
	__gshared uint NumEntries;

	struct IOAPICInfo {
		ubyte ID;
		ubyte Ver;
		bool Enabled;
		PhysicalAddress Address;
	}

	__gshared IOAPICInfo[16] IOAPICs;
	__gshared uint NumIOAPICs;

	struct LAPICInfo {
		ubyte ID;
		ubyte Ver;
		bool Enabled;
	}

	__gshared PhysicalAddress LocalAPICAddress;
	__gshared LAPICInfo[256] LAPICs;
	__gshared uint NumLAPICs;
}
