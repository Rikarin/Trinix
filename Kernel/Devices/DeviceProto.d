module Devices.DeviceProto;

import Architectures.Core;


abstract class DeviceProto {
public:
	void IRQHandler(ref InterruptStack r) {}
}
