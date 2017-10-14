/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module VFSManager.BlockNode;

import VFSManager;


abstract class BlockNode : FSNode {
    @property long Blocks();
    @property long BlockSize();

    this(DirectoryNode parent, FileAttributes attributes) {
        m_attributes = attributes;
        m_attributes.Type = FileType.BlockDevice;

        super(parent);
    }
}