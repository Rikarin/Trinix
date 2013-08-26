/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
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
     *      instance of mounted partition
     */
    @property Partition GetPartition(); 

    /**
     * Getter
     * 
     * Returns:
     *      true if mounted filesystem is writable
	 *
	 * TODO:
	 *     o Rename this to 'CanWrite'
     */
    @property bool IsWritable();

    /**
     * Getter
     * 
     * Returns:
     *      object of root directory of the filesystem
     */
    @property DirectoryNode RootNode();

    /**
     * Unmount the filesystem
     * 
     * Returns:
     *      true if filesystem was unmounted successfuly
     */
    bool Unmount();

    /**
     * Load content of directory node and automaticaly add found
     * nodes into direcotry node
     * 
     * Params:
     *      node    =       node of directory what we want to load
     * 
     * Returns:
     *      true if content was loaded successfuly
     */
    bool LoadContent(DirectoryNode node);

    /**
     * Create new node in specific directory
     * 
     * Params:
     *      parent      =       directory where we want to create a node
     *      attributes  =       attributes of creating node
     * 
     * Returns:
     *      object of created node
     */
    FSNode Create(DirectoryNode parent, FileAttributes attributes);

    /**
     * Remove node from filesystem.
     * This will be called only from FSNode.Remove method
     * 
     * Params:
     *      node    =       node what we want to remove
     * 
     * Returns:
     *      true if node was removed successfuly
     */
    bool Remove(FSNode node);
}