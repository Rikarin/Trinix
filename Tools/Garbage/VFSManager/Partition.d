/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module VFSManager.Partition;

import Library;
import VFSManager;
import ObjectManager;


final class Partition : BlockNode {
    private __gshared char[] m_diskName = cast(char[])"disk0";

    private BlockCache m_cache;
    private long m_offset;
    private long m_length;

    private struct MBREntry {
    align(1):
        ubyte Bootable;
        ubyte StartHead;
        private ushort m_startSC;
        ubyte ID;
        ubyte EndHead;
        private ushort m_endSC;
        uint StartLBA;
        uint Size;

        mixin(Bitfield!(m_startSC, "StartSector", 6, "StartCylinder", 10));
        mixin(Bitfield!(m_endSC, "EndSector", 6, "EndCylinder", 10));
    }

    @property private static string NextDiskName() {
        char[] ret = m_diskName.dup;
        m_diskName[$ - 1]++;

        return cast(string)ret;
    }

    @property IBlockDevice Device() {
        return m_cache.Device;
    }

    @property override long Blocks() {
        return m_length;
    }
    @property override long BlockSize() {
        return m_cache.Device.BlockSize;
    }

    this(IBlockDevice device, long offset, long length, DirectoryNode parent, FileAttributes attributes) {
        m_cache  = new BlockCache(device, 0x100);
        m_offset = offset;
        m_length = length;

        super(parent, attributes);
    }

    ~this() {
        delete m_cache;
    }

    override ulong Read(long offset, byte[] data) {
        if (offset > m_length)
            return 0;
        
        long len = offset + data.length > m_length ? m_length - offset : data.length;
        return m_cache.Read(m_offset + offset, data[0 .. len]);
    }

    override ulong Write(long offset, byte[] data) {
        if (offset > m_length)
            return 0;
        
        long len = offset + data.length > m_length ? m_length - offset : data.length;
        return m_cache.Write(m_offset + offset, data[0 .. len]);
    }

    static void ReadTable(IBlockDevice device) {
        string name = NextDiskName;
        new Partition(device, 0, device.Blocks, DeviceManager.DevFS, FileAttributes(name));

        byte[512] mbr;
        if (device.Read(0, mbr) != 512)
            return;

        MBREntry* entry = cast(MBREntry *)(cast(ulong)mbr.ptr + 0x1BE);
        foreach (i, x; entry[0 .. 4]) {
            if ((x.Bootable == 0 || x.Bootable == 0x80) && x.ID && x.StartLBA < device.Blocks && x.Size < device.Blocks)
                new Partition(device, x.StartLBA, x.Size, DeviceManager.DevFS, FileAttributes(name ~ 's' ~ cast(char)('1' + i)));
        }
    }
}