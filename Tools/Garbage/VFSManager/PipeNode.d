/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module VFSManager.PipeNode;

import VFSManager;


abstract class PipeNode : FSNode {
    this(DirectoryNode parent, FileAttributes attributes) {
        m_attributes = attributes;
        m_attributes.Type = FileType.Pipe;
        
        super(parent);
    }
}