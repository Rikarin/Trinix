module Drivers.DeviceProto;

import Architectures;


abstract class DeviceProto {
public:
	void IRQHandler(ref InterruptStack r) {}
}
