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

module VFSManager.IFileSystem;

import VFSManager;


/**
 * This interface is inherted by every filesystem driver like devfs, ext2, etc.
 * Provide a common methods for work with filesystem
 * 
 */
interface IFileSystem {
	/**
	 * Getter
	 * 
	 * Returns:
	 * 		instance of mounted partition
	 */
	@property Partition GetPartition(); 

	/**
	 * Getter
	 * 
	 * Returns:
	 * 		true if mounted filesystem is writable
	 */
	@property bool IsWritable();

	/**
	 * Getter
	 * 
	 * Returns:
	 * 		object of root directory of the filesystem
	 */
	@property DirectoryNode RootNode();

	/**
	 * Unmount the filesystem
	 * 
	 * Returns:
	 * 		true if filesystem was unmounted successfuly
	 */
	bool Unmount();

	/**
	 * Load content of directory node and automaticaly add found
	 * nodes into direcotry node
	 * 
	 * Params:
	 * 		node	=		node of directory what we want to load
	 * 
	 * Returns:
	 * 		true if content was loaded successfuly
	 */
	bool LoadContent(DirectoryNode node);

	/**
	 * Create new node in specific directory
	 * 
	 * Params:
	 * 		parent		=		directory where we want to create a node
	 * 		attributes	=		attributes of creating node
	 * 
	 * Returns:
	 * 		object of created node
	 */
	FSNode Create(DirectoryNode parent, FileAttributes attributes);

	/**
	 * Remove node from filesystem.
	 * This will be called only from FSNode.Remove method
	 * 
	 * Params:
	 * 		node	=		node what we want to remove
	 * 
	 * Returns:
	 * 		true if node was removed successfuly
	 */
	bool Remove(FSNode node);
}