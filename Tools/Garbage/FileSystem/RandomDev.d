/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module FileSystem.RandomDev;

import VFSManager;
import Architecture;


final class RandomDev : CharNode {
    private __gshared ulong m_number;

    this(DirectoryNode parent, string name) {
        super(parent, FileAttributes(name));

        m_attributes.Length = 1024;
    }
    
    override ulong Read(long offset, byte[] data) {
        foreach (ref x; data) {
            m_number = (Rand1() - Rand2() + Rand3()) * Time.Now;
            x = cast(byte)(m_number & 0xFF);
        }

        return data.length;
    }
    
    override ulong Write(long offset, byte[] data) {
        return 0;
    }

    private ulong Rand1() { return (m_number * 125) % 2796203; }
    private ulong Rand2() { return (m_number * 32719 + 3) % 32749; }
    private ulong Rand3() { return (((m_number * 214013L + 2531011L) >> 16) & 32767); }
}