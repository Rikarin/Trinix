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

module VFSManager.Partition;

import Library;
import VFSManager;
import ObjectManager;


final class Partition : BlockNode {
	private __gshared char[] _diskName = cast(char[])"disk0";

	private BlockCache _cache;
	private long _offset;
	private long _length;

	private struct MBREntry {
	align(1):
		ubyte Bootable;
		ubyte StartHead;
		private ushort _startSC;
		ubyte ID;
		ubyte EndHead;
		private ushort _endSC;
		uint StartLBA;
		uint Size;

		mixin(Bitfield!(_startSC, "StartSector", 6, "StartCylinder", 10));
		mixin(Bitfield!(_endSC, "EndSector", 6, "EndCylinder", 10));
	}

	@property private static string NextDiskName() {
		char[] ret = _diskName.dup;
		_diskName[$ - 1]++;

		return cast(string)ret;
	}

	@property IBlockDevice Device() {
		return _cache.Device;
	}

	@property override long Blocks() {
		return _length;
	}
	@property override long BlockSize() {
		return _cache.Device.BlockSize;
	}

	this(IBlockDevice device, long offset, long length, DirectoryNode parent, FileAttributes attributes) {
		_cache  = new BlockCache(device, 0x1);
		_offset = offset;
		_length = length;

		super(parent, attributes);
	}

	~this() {
		delete _cache;
	}

	override ulong Read(long offset, byte[] data) {
		if (offset > _length)
			return 0;
		
		long len = offset + data.length > _length ? _length - offset : data.length;
		return Device.Read(_offset + offset, data[0 .. len]); //TODO: cache
	}

	override ulong Write(long offset, byte[] data) {
		if (offset > _length)
			return 0;
		
		long len = offset + data.length > _length ? _length - offset : data.length;
		return Device.Write(_offset + offset, data[0 .. len]); //TODO: cache
	}

	static void ReadTable(IBlockDevice device) {
		string name = NextDiskName;
		new Partition(device, 0, device.Blocks, DeviceManager.DevFS, FSNode.NewAttributes(name));

		byte[512] mbr;
		if (device.Read(0, mbr) != 512)
			return;

		MBREntry* entry = cast(MBREntry *)(cast(ulong)mbr.ptr + 0x1BE);
		foreach (i, x; entry[0 .. 4]) {
			if ((x.Bootable == 0 || x.Bootable == 0x80) && x.ID && x.StartLBA < device.Blocks && x.Size < device.Blocks)
				new Partition(device, x.StartLBA, x.Size, DeviceManager.DevFS, FSNode.NewAttributes(name ~ 's' ~ cast(char)('1' + i)));
		}
	}
}