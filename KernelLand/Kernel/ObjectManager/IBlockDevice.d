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

module ObjectManager.IBlockDevice;


/**
 * This interface is inherted by every block device/driver and provide a common
 * method to communicate.
 * 
 */
interface IBlockDevice {
	/**
	 * Getter
	 * 
	 * Returns:
	 * 		number of block in block device
	 */
	@property long Blocks();

	/**
	 * Getter
	 * 
	 * Returns:
	 * 		size of block in bytes
	 */
	@property int BlockSize();

	/**
	 * Read from block device
	 * 
	 * Params:
	 * 		offset	=		where start reading
	 * 		data	=		initialized array where length detemine how many
	 * 						bytes will be red
	 * 
	 * Returns:
	 * 		length of red data. Will be less or equals to data.length
	 */
	ulong Read(long offset, byte[] data);

	/**
	 * Write to block device
	 * 
	 * Params:
	 * 		offset	=		where to write
	 * 		data	=		source array with data.
	 * 
	 * Returns:
	 * 		length of written data. Will be less or equals to data.length
	 */
	ulong Write(long offset, byte[] data);
}