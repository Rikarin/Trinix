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

module FileSystem.DevFS;

import VFSManager;


final class DevFS : IFileSystem {
	private DirectoryNode m_rootNode;

	private this() {

	}
	
	@property Partition GetPartition() {
		return null;
	}

	@property bool IsWritable() {
		return true;
	}

	@property DirectoryNode RootNode() {
		return m_rootNode;
	}
	
	bool Unmount() {
		return true;
	}
	
	bool LoadContent(DirectoryNode node) {
		return true;
	}

	FSNode Create(DirectoryNode parent, FileAttributes attributes) {
		switch (attributes.Type) {
			case FileType.Directory:
				return new DirectoryNode(parent, attributes);

			default:
				return null;
		}
	}

	bool Remove(FSNode node) {
		switch (node.Attributes.Type) {
			case FileType.Directory:
				if (!(cast(DirectoryNode)node).Childrens.Count) {
					delete node;
					return true;
				}
				break;

			default:
				delete node;
				return true;
		}

		return false;
	}

	static DevFS Mount(DirectoryNode mountpoint) {
		if (mountpoint is null || !mountpoint.IsMountpointable)
			return null;

		DevFS ret = new DevFS();
		ret.m_rootNode = new DirectoryNode(null, FSNode.NewAttributes("/"));
		ret.m_rootNode.FileSystem = ret;

		if (!mountpoint.Mount(ret.m_rootNode)) {
			delete ret;
			return null;
		}

		return ret;
	}

	bool AddDevice(FSNode dev) {
		return false;
	}
}