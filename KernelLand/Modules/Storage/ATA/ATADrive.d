/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module Modules.Storage.ATA.ATADrive;

import VFSManager;
import ObjectManager;
import Modules.Storage.ATA.ATAController;


class ATADrive : IBlockDevice {
	private ATAController _controller;
	private bool _isSlave;
	private uint _blockCount;
	private short[] _data;

	@property long Blocks() {
		return _blockCount;
	}

	@property int BlockSize() {
		return 512;
	}

	package this(ATAController controlller, bool isSlave, uint blockCount, short[] data) {
		_controller = controlller;
		_isSlave    = isSlave;
		_blockCount = blockCount;
		_data       = data;
	}

	~this() {
		foreach (x; DeviceManager.DevFS.Childrens) {
			Partition part = cast(Partition)x.Value;
			if (part !is null && part.Device == this)
				delete x.Value;
		}

		delete _data;
	}

	ulong Read(long offset, byte[] data) {
		ulong blockCount = data.length / BlockSize + ((data.length % BlockSize) != 0);

		if (offset + blockCount >= Blocks)
			return 0;
		
		_controller.Lock();
		CmdCommon(offset, cast(byte)blockCount);
		_controller.Write!byte(ATAController.Port.Command, ATAController.Cmd.Read);
		while (!(_controller.Read!byte(ATAController.Port.Command) & 0x08)) { }
		
		for (long i; i < data.length;) {
			short tmp = _controller.Read!short(ATAController.Port.Data);
			data[i++] = cast(byte)(tmp & 0xFF);
			data[i++] = tmp >> 8;
		}

		/* flush buffer */
		for (ulong i = 0; i < BlockSize; i++)
			_controller.Read!short(ATAController.Port.Data);
		
		_controller.Unlock();
		return data.length;
	}

	ulong Write(long offset, byte[] data) {
		ulong blockCount = data.length / BlockSize + ((data.length % BlockSize) != 0);

		if (offset + blockCount > Blocks)
			return 0;
		
		_controller.Lock();
		CmdCommon(offset, cast(byte)blockCount);
		_controller.Write!byte(ATAController.Port.Command, ATAController.Cmd.Write);
		while (!(_controller.Read!byte(ATAController.Port.Command) & 0x08)) { }
		
		for (long i; i < data.length;)
			_controller.Write!short(ATAController.Port.Data, cast(byte)(data[i++] | (data[i++] << 8)));

		//TODO flush buffer?
		
		_controller.Unlock();
		return data.length;
	}

	private void CmdCommon(ulong offset, byte count) {
		_controller.Write!byte(ATAController.Port.FeaturesError, 0);
		_controller.Write!byte(ATAController.Port.SectCount, count);
		
		_controller.Write!byte(ATAController.Port.Partial1, cast(byte)(offset & 0xFF));
		_controller.Write!byte(ATAController.Port.Partial2, cast(byte)((offset >> 8) & 0xFF));
		_controller.Write!byte(ATAController.Port.Partial3, cast(byte)((offset >> 16) & 0xFF));
		
		_controller.Write!byte(ATAController.Port.DriveSelect, cast(byte)(0xE0 | (_isSlave ? 0x10 : 0) | ((offset >> 24) & 0x0F)));
	}
}