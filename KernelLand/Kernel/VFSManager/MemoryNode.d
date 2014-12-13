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

module VFSManager.MemoryNode;

import VFSManager;


class MemoryNode : FSNode {
	private byte[] _buffer;

	this(byte[] buffer, DirectoryNode parent, FileAttributes fileAttributes) {
		_buffer          = buffer;
		_attributes      = fileAttributes;
		_attributes.Type = FileType.CharDevice;
		
		super(parent);
	}
	
	override ulong Read(long offset, byte[] data) {
		if (offset > _buffer.length)
			return 0;

		long len = offset + data.length > _buffer.length ? _buffer.length - offset : data.length;
		data[] = (cast(byte *)_buffer)[offset .. len];

		return len;
	}
	
	override ulong Write(long offset, byte[] data) {
		if (offset > _buffer.length)
			return 0;
		
		long len = offset + data.length > _buffer.length ? _buffer.length - offset : data.length;
		(cast(byte *)_buffer)[offset .. len] = data[];

		return len;
	}
}