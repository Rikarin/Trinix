/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module VFSManager.CharNode;

import VFSManager;


abstract class CharNode : FSNode {
    this(DirectoryNode parent, FileAttributes attributes) {
        m_attributes = attributes;
        m_attributes.Type = FileType.CharDevice;

        super(parent);
    }
}