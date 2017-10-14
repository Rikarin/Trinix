/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module VFSManager.FSNode;

import Library;
import VFSManager;
import TaskManager;
import Architecture;
import ObjectManager;

import System.Runtime;


/**
 * Base Node of the virtual file system
 * 
 */
abstract class FSNode : Resource {
    private enum IDENTIFIER = "com.trinix.VFSManager.FSNode";

    package DirectoryNode m_parent;
    protected FileAttributes m_attributes;

    /**
     * Constructor must be always called from child class
     * 
     * Params:
     *      parent  =       parent node of the filesystem
     *                      null if is freestanding
     */
    protected this(DirectoryNode parent) {
        CallTable[] callTable = [
            { ".Read",          3, Callback3: &Syscall_Read          },
            { ".Write",         3, Callback3: &Syscall_Write         },
            { ".GetAttributes", 1, Callback1: &Syscall_GetAttributes },
            { ".SetAttributes", 1, Callback1: &Syscall_SetAttributes },
        ];

        if (parent !is null) {
            m_parent = parent;
            parent.Childrens.Add(this);
        }

        super(DeviceType.Disk, IDENTIFIER, 0x01, callTable);
    }

    /**
     * Remove this node from his parent. This doesn't remove it 
     * from filesystem.
     * 
     */
    ~this() {
        if (m_parent !is null)
            m_parent.Childrens.Remove(this);

        delete m_attributes.Name;
    }

    /**
     * Getter
     * 
     * Returns: 
     *      parent of this node
     */
    @property DirectoryNode Parent() {
        return m_parent;
    }

    /**
     * Getter
     * 
     * Returns:
     *      attributes of this node
     */
    @property FileAttributes Attributes() {
        return m_attributes;
    }

    /**
     * Setter
     * 
     * Params:
     *      value   =       attributes what we want to set
     */
    @property void Attributes(FileAttributes value) {
        m_attributes = value;
    }

    /**
     * Read raw data from inode
     * 
     * Params:
     *      offset  =       where start reading
     *      data    =       initialized destination array. Must be set length
     * 
     * Returns:
     *      length of red data. Will be less or equals to data.length
     */
    ulong Read(long offset, byte[] data) {
        return 0;
    }

    /**
     * Write data to inode
     * 
     * Params:
     *      offset  =       where to write
     *      data    =       source array with data.
     * 
     * Returns:
     *      length of written data. Will be less or equals to data.length
     */
    ulong Write(long offset, byte[] data) {
        return 0;
    }

    /**
     * Remove this node from filesystem (disk, floppy, etc.)
     * 
     * Returns:
     *      true if this node was removed successfuly
     */
    bool Remove() {
        if (m_parent is null || m_parent.FileSystem is null)
            return false;

        if (m_attributes.Type == (FileType.Directory | FileType.Mountpoint) 
            && (cast(DirectoryNode)this).Childrens.Count)
            return false;
            
        return m_parent.FileSystem.Remove(this);
    }

    string Location() {
        scope auto sb = new StringBuilder();
        FSNode node   = this;

        while (node !is null) {
            if (node.Attributes.Name != "/") {
                sb.Insert(0, node.Attributes.Name);
                sb.Insert(0, "/");
            }
            node = node.Parent;
        }

        if (!sb.Length)
            return "/";

        return sb.ToString();
    }

    override bool DetachProcess(Process process) {
        super.DetachProcess(process);
        return false;
    }

/* ============================= START SYSCALL ============================= */
    private long Syscall_GetAttributes(long attribPtr) {
        if (!IsValidAddress(attribPtr))
            return SyscallReturn.Error;

        *(cast(FileAttributes *)attribPtr) = Attributes;
        return SyscallReturn.Successful;
    }

    private long Syscall_SetAttributes(long attribPtr) {
        if (!IsValidAddress(attribPtr))
            return SyscallReturn.Error;

        Attributes = *(cast(FileAttributes *)attribPtr);
        return SyscallReturn.Successful;
    }

    private long Syscall_Read(long offset, long bufferPtr, long length) {
        if (!IsValidAddress(bufferPtr))
            return SyscallReturn.Error;

        return Read(offset, (cast(byte *)bufferPtr)[0 .. length]);
    }

    private long Syscall_Write(long offset, long bufferPtr, long length) {
        if (!IsValidAddress(bufferPtr))
            return SyscallReturn.Error;

        return Write(offset, (cast(byte *)bufferPtr)[0 .. length]);
    }
/* ============================== END SYSCALL ============================== */
}