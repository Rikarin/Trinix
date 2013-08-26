/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module FileSystem.ZeroDev;

import VFSManager;


final class ZeroDev : CharNode {
    this(DirectoryNode parent, string name) {
        super(parent, FileAttributes(name));
    }
    
    override ulong Read(long offset, byte[] data) {
        if (data.length < 1)
            return 0;

        data[0] = 1;
        return 1;
    }
    
    override ulong Write(long offset, byte[] data) {
        return 0;
    }
}