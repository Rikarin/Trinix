module Devices.BlockDeviceProto;

import Devices.DeviceProto;


abstract class BlockDeviceProto : DeviceProto {
	@property ulong Blocks() const;
	@property uint BlockSize() const;
	
	bool Read(ulong startBlock, out byte[] data);
	bool Write(ulong startBlock, in byte[] data);
}