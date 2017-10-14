/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
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