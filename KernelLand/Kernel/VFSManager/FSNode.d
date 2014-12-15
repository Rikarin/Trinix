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

module VFSManager.FSNode;

import VFSManager;
import TaskManager;
import Architecture;
import ObjectManager;
import SyscallManager;


/**
 * Base Node of the virtual file system
 * 
 */
abstract class FSNode : Resource {
	package DirectoryNode _parent;
	protected FileAttributes _attributes;

	/**
	 * Constructor must be always called from child class
	 * 
	 * Params:
	 * 		parent	= 		parent node of the filesystem
	 * 						null if is freestanding
	 */
	protected this(DirectoryNode parent) {
		static const ResouceCallTable rcs = {
            "com.trinix.VFSManager.FSNode",
            &StaticCallback
        };

		static const CallTable[] callTable = [
			{0, ".Attributes", 0, null}
		];

		if (parent !is null) {
			_parent = parent;
			parent.Childrens.Add(this);
		}

		ResourceManager.AddCallTable(rcs); //TODO move this to VFS.Initialize()
		super(DeviceType.Disk, "com.trinix.VFSManager.FSNode", 0x01, callTable);
	}

	/**
	 * Remove this node from his parent. This doesn't remove it 
	 * from filesystem.
	 * 
	 */
	~this() {
		if (_parent !is null)
			_parent.Childrens.Remove(this);

		delete _attributes.Name;
	}

	/**
	 * Getter
	 * 
	 * Returns: 
	 * 		parent of this node
	 */
	@property DirectoryNode Parent() {
		return _parent;
	}

	/**
	 * Getter
	 * 
	 * Returns:
	 * 		attributes of this node
	 */
	@property FileAttributes Attributes() {
		return _attributes;
	}

	/**
	 * Setter
	 * 
	 * Params:
	 * 		value	=		attributes what we want to set
	 */
	@property void Attributes(FileAttributes value) {
		_attributes = value;
	}

	/**
	 * Read raw data from inode
	 * 
	 * Params:
	 * 		offset	=		where start reading
	 * 		data	=		initialized destination array. Must be set length
	 * 
	 * Returns:
	 * 		length of red data. Will be less or equals to data.length
	 */
	ulong Read(long offset, byte[] data) {
		return 0;
	}

	/**
	 * Write data to inode
	 * 
	 * Params:
	 * 		offset	=		where to write
	 * 		data	=		source array with data.
	 * 
	 * Returns:
	 * 		length of written data. Will be less or equals to data.length
	 */
	ulong Write(long offset, byte[] data) {
		return 0;
	}

	/**
	 * Remove this node from filesystem (disk, floppy, etc.)
	 * 
	 * Returns:
	 * 		true if this node was removed successfuly
	 */
	bool Remove() {
		if (_parent is null || _parent.FileSystem is null)
			return false;

		if (_attributes.Type == (FileType.Directory | FileType.Mountpoint) 
		    && (cast(DirectoryNode)this).Childrens.Count)
			return false;
			
		return _parent.FileSystem.Remove(this);
	}

	/**
	 * Create a basic structure of new file sttributes with UID and GID of current
	 * running process, current time and 644 permissions.
	 * 
	 * Params:
	 * 		name	=		name of node used this attriutes
	 * 		type	=		type of node like file, directory, pipe, etc.
	 * 
	 * Returns:
	 * 		a valid struct of attributes
	 */
	static FileAttributes NewAttributes(string name, FileType type = FileType.Directory) {
		FileAttributes ret;
		ret.Name        = name;
		ret.Type        = type;
		ret.Permissions = FilePermissions.UserRead  | FilePermissions.UserWrite 
						| FilePermissions.GroupRead | FilePermissions.OtherRead;
		ret.UID         = Task.CurrentProcess.UID;
		ret.GID         = Task.CurrentProcess.GID;
		ret.AccessTime  = Time.Now;
		ret.ModifyTime  = ret.AccessTime;
		ret.CreateTime  = ret.AccessTime;

		return ret;
	}

	/**
	 * Callback used by userspace apps for obtaining instance of speciffic classes
	 * by calling this static syscall
	 * 
	 * Params:
	 * 		param1	=		TODO
	 * 		param2	=		TODO
	 * 		param3	=		TODO
	 * 		param4	=		TODO
	 * 		param5	=		TODO
	 * 
	 * Returns:
	 * 		-1				on failure
	 */
	static long StaticCallback(long param1, long param2, long param3, long param4, long param5) {
		return -1;
	}
}