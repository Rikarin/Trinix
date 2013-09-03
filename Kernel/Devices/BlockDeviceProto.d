module Devices.BlockDeviceProto;

import Devices.DeviceProto;


abstract class BlockDeviceProto : DeviceProto {
	@property ulong Blocks() const;
	@property uint BlockSize() const;
	
	bool Read(ulong startBlock, byte[] data);
	bool Write(ulong startBlock, byte[] data);
}