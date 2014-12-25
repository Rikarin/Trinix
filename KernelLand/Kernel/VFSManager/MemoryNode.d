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
 * http://bit.ly/1wIYh3A and read it before using this file.
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
	private byte[] m_buffer;

	this(byte[] buffer, DirectoryNode parent, FileAttributes fileAttributes) {
		m_buffer          = buffer;
		m_attributes      = fileAttributes;
		m_attributes.Type = FileType.CharDevice;
		
		super(parent);
	}
	
	override ulong Read(long offset, byte[] data) {
		if (offset > m_buffer.length)
			return 0;

		long len = offset + data.length > m_buffer.length ? m_buffer.length - offset : data.length;
		data[] = (cast(byte *)m_buffer)[offset .. len];

		return len;
	}
	
	override ulong Write(long offset, byte[] data) {
		if (offset > m_buffer.length)
			return 0;
		
		long len = offset + data.length > m_buffer.length ? m_buffer.length - offset : data.length;
		(cast(byte *)m_buffer)[offset .. len] = data[];

		return len;
	}
}