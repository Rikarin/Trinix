/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module FileSystem.NullDev;

import VFSManager;


final class NullDev : CharNode {
    this(DirectoryNode parent, string name) {
        super(parent, FileAttributes(name));
    }

    override ulong Read(long offset, byte[] data) {
        return 0;
    }

    override ulong Write(long offset, byte[] data) {
        return 0;
    }
}