module Architectures.x86_64.Core.SystemSegmentType;


public enum SystemSegmentType : ubyte {
	LocalDescriptorTable = 0b0010,
	AvailableTSS         = 0b1001,
	BusyTSS              = 0b1011,
	CallGate             = 0b1100,
	InterruptGate        = 0b1110,
	TrapGate             = 0b1111
}