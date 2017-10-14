/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Library.File;

import VFSManager;


class File {
    FSNode m_node;
    long m_pos;

    this(FSNode node) {
        m_node = node;
    }

    @property ref long Position() { return m_pos; }

    long Read(byte[] buffer) {
        long len = m_node.Read(m_pos, buffer);
        m_pos   += len;
        
        return len;
    }

    void Write(byte[] buffer) {
        long len = m_node.Write(m_pos, buffer);
        m_pos   += len;
    }
}