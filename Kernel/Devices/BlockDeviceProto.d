module Devices.BlockDeviceProto;

import Devices;


abstract class BlockDeviceProto : DeviceProto {
	@property ulong Blocks() const;
	@property uint BlockSize() const;
	
	ulong Read(ulong offset, byte[] data);
	ulong Write(ulong offset, byte[] data);
}