module Devices.Keyboard.KeyboardProto;

import Devices.DeviceProto;


abstract class KeyboardProto : DeviceProto {
	~this() { }

	void UpdateLeds(ubyte status);
}