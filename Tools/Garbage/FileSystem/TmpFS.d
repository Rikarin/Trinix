/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module FileSystem.TmpFS;

import VFSManager;


final class TmpFS : IFileSystem {
    private DirectoryNode m_rootNode;

    @property Partition GetPartition()   { return null; }
    @property bool IsWritable()          { return true; }
    @property DirectoryNode RootNode()   { return m_rootNode; }
    
    private this()                       { }
    bool Unmount()                       { return true; }
    bool LoadContent(DirectoryNode node) { return true; }
    
    private ulong Read(TmpFileNode node, long offset, byte[] data) {
        if (offset >= node.Attributes.Length)
            return 0;

        long length = node.Attributes.Length - offset;
        if (length > data.length)
            length = data.length;

        data[] = node.m_data[offset .. offset + length];
        return length;
    }
    
    private ulong Write(TmpFileNode node, long offset, byte[] data) {
        long end = offset + data.length;

        if (end > node.Attributes.Length) {
            byte[] tmp = new byte[end];

            if (node.m_data !is null) {
                tmp[0 .. node.m_data.length] = node.m_data[];
                delete node.m_data;
            }

            node.m_data = tmp;
        }

        node.m_data[offset .. end] = data[];
        return data.length;
    }

    FSNode Create(DirectoryNode parent, FileAttributes attributes) {
        switch (attributes.Type) {
            case FileType.Directory:
                return new DirectoryNode(parent, attributes);

            case FileType.File:
                return new TmpFileNode(parent, attributes);
                
            default:
                return null;
        }
    }
    
    bool Remove(FSNode node) {
        if (node.Attributes.Type == FileType.File) {
            auto n = cast(TmpFileNode)node;
            if (n.m_data !is null)
                delete n.m_data;
        }

        return true;
    }
    
    static TmpFS Mount(DirectoryNode mountpoint) {
        if (mountpoint is null || !mountpoint.IsMountpointable)
            return null;
        
        TmpFS ret = new TmpFS();
        ret.m_rootNode = new DirectoryNode(null, FileAttributes("/"));
        ret.m_rootNode.FileSystem = ret;
        
        if (!mountpoint.Mount(ret.m_rootNode)) {
            delete ret;
            return null;
        }
        
        return ret;
    }
}


final class TmpFileNode : FileNode {
    private byte[] m_data;
    
    
    @property override FileAttributes Attributes() {
        m_attributes.Length = m_data.length;
        return m_attributes;
    }
    
    this(DirectoryNode parent, FileAttributes fileAttributes) {
        super(parent, fileAttributes);
    }

    ~this() {
        delete m_data;
    }

    override ulong Read(long offset, byte[] data) {
        if (m_parent is null || m_parent.FileSystem is null)
            return 0;
        
        return (cast(TmpFS)m_parent.FileSystem).Read(this, offset, data);
    }
    
    override ulong Write(long offset, byte[] data) {
        if (m_parent is null || m_parent.FileSystem is null)
            return 0;
        
        return (cast(TmpFS)m_parent.FileSystem).Write(this, offset, data);
    }
}