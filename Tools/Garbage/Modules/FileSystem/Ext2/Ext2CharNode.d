/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Modules.FileSystem.Ext2.Ext2CharNode;

import VFSManager;
import Modules.FileSystem.Ext2;


final class Ext2CharNode : CharNode {
    private DiskNode m_node;
    private bool m_loadedAttribs;

    @property auto Node() { return m_node; }

    this(int inode, DirectoryNode parent, FileAttributes attributes) {
        m_node = DiskNode(parent, inode);
        super(parent, attributes);
    }
    
    @property override FileAttributes Attributes() {
      /*  if (!m_loadedAttribs && m_parent !is null && m_parent.FileSystem !is null) {
            auto attribs = (cast(Ext2FileSystem)m_parent.FileSystem).GetAttributes(Node.Inode);
            attribs.Name = m_attributes.Name;
            attribs.Type = m_attributes.Type;

            m_attributes    = attribs;
            m_loadedAttribs = true;
        }*/
        
        return m_attributes;
    }
    
    @property override void Attributes(FileAttributes value) {
        m_attributes = value;

        if (m_parent !is null && m_parent.FileSystem !is null)
            (cast(Ext2FileSystem)m_parent.FileSystem).SetAttributes(Node, m_attributes);
    }
    
    override ulong Read(long offset, byte[] data) {
        if (m_parent is null || m_parent.FileSystem is null)
            return 0;
        
        return (cast(Ext2FileSystem)m_parent.FileSystem).Read(Node.Node, offset, data);
    }
    
    override ulong Write(long offset, byte[] data) {
        if (m_parent is null || m_parent.FileSystem is null)
            return 0;
        
        return (cast(Ext2FileSystem)m_parent.FileSystem).Write(Node.Node, offset, data);
    }
}