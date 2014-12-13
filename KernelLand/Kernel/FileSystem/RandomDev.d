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

module FileSystem.RandomDev;

import VFSManager;
import Architecture;


final class RandomDev : CharNode {
	private __gshared ulong _number;

	this(DirectoryNode parent, string name) {
		super(parent, NewAttributes(name));

		_attributes.Length = 1024;
	}
	
	override ulong Read(long offset, byte[] data) {
		foreach (ref x; data) {
			_number = (Rand() - Rand2() + Rand3()) * Time.Now;
			x = cast(byte)(_number & 0xFF);
		}

		return data.length;
	}
	
	override ulong Write(long offset, byte[] data) {
		return 0;
	}

	private ulong Rand() {
		return (_number * 125) % 2796203;
	}

	private ulong Rand2() {
		return (_number * 32719 + 3) % 32749;
	}

	private ulong Rand3() {
		return (((_number * 214013L + 2531011L) >> 16) & 32767);
	}
}