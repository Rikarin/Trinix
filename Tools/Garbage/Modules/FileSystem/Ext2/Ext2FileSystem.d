﻿/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Modules.FileSystem.Ext2.Ext2FileSystem;

import Core;
import Library;
import VFSManager;
import Architecture;
import ObjectManager;
import Modules.FileSystem.Ext2;


struct DiskNode {
    private int m_inode;
    private Ext2FileSystem m_fs;

    @property package int Number() {
        return m_inode;
    }

    @property package auto Node() {
        Ext2FileSystem.Inode ret;

        if (m_fs !is null)
            m_fs.ReadInode(ret, m_inode);

        return ret;
    }

    @property package void Node(Ext2FileSystem.Inode node) {
        if (m_fs !is null)
            m_fs.WriteInode(node, m_inode);
    }

    package this(DirectoryNode parent, int node) {
        if (parent !is null)
            m_fs = cast(Ext2FileSystem)parent.FileSystem;

        m_inode = node;
    }
}

final class Ext2FileSystem : IFileSystem {
    private Ext2DirectoryNode m_rootNode;
    private Partition m_partition;
    private Superblock m_superblock;
    private Group[] m_groups;
    private bool m_groupsDirty;
    private bool m_superblockDirty;

    private struct Superblock {
    align(1):
        uint NumInodes;
        uint NumBlocks;
        uint NumReservedBlocks;
        uint NumFreeBlocks;
        uint NumFreeInodes;
        uint SuperblockBlock;
        uint BlockSize;
        uint FragmentSize;
        uint BlocksPerGroup;
        uint FragmentsPerGroup;
        uint InodesPerGroup;
        uint LastMountTime;
        uint LastWriteTime;
        ushort MountCount;
        ushort MaxMountCount;
        ushort Signature;
        ushort FSState;
        ushort ErrorMethod;
        ushort VersionMinor;
        uint LastCheckTime;
        uint CheckInterval;
        uint OperatingSystem;
        uint VersionMajor;
        ushort UID;
        ushort GID;
        
        /* Extended superblock fields */
        uint FirstInode;
        ushort InodeSize;
        ushort SuperblockGroup;
        uint OptionalFeatres;
        uint RequiredFeatures;
        uint ReadWriteFeatures;
        char[16] FSID;
        char[16] VolumeName;
        char[64] LastPath;
        uint Compression;
        ubyte FileStartBlocks;
        ubyte DirStartBlocks;
        private byte[2] m_unused;
        char[2] JournalID;
        uint JournalInode;
        uint JournalDevice;
        uint OrphanInodesHead;
    }

    private struct Inode {
    align(1):
        ushort Type;
        ushort UID;
        uint SizeLow;
        uint ATime;
        uint CTime;
        uint MTime;
        uint DTime;
        ushort GID;
        ushort LinkCount;
        uint DiskSectors;
        uint Flags;
        uint OSVal1;
        uint[12] Direct;
        uint Indirect;
        uint Dindirect;
        uint Tindirect;
        uint Generation;
        uint ExtendedAttributes;
        uint SizeHigh;
        uint FragmentBlock;
        uint[12] OSVal2;
    }

    private struct Group {
    align(1):
        uint BlockBitmap;
        uint InodeBitmap;
        uint InodeTable;
        ushort UnallocatedBlocks;
        ushort UnallocatedInodes;
        ushort NumDir;
        private ushort[7] m_unused;
    }

    private struct DirInfo {
    align(1):
        uint Inode;
        ushort RecordLength;
        ubyte NameLength;
        ubyte FileType;
        char[1] Name;
    }

    private enum DirFileType {
        Unknown,
        File,
        Directory,
        CharDevice,
        BlockDevice,
        FIFO,
        Socket,
        SymLink
    }

    private enum InodeType {
        OX = 1,
        OW = 2,
        OR = 4,
        GX = 8,
        GW = 16,
        GR = 32,
        UX = 64,
        UW = 128,
        UR = 256,

        FIFO        = 0x1000,
        CharDevice  = 0x2000,
        Directory   = 0x4000,
        BlockDevice = 0x6000,
        File        = 0x8000,
        SymLink     = 0xA000,
        Socket      = 0xC000
    }

    @property uint BlockSize()                  { return 1024 << m_superblock.BlockSize; }
    @property uint NumGroups()                  { return (m_superblock.NumInodes / m_superblock.InodesPerGroup) + (m_superblock.NumInodes % m_superblock.InodesPerGroup != 0); }
    @property override Partition GetPartition() { return m_partition; }
    @property bool IsWritable()                 { return true;        }
    @property DirectoryNode RootNode()          { return m_rootNode;  }

    private this(Partition partition) {
        m_partition = partition;
        m_partition.Read(2, (cast(byte *)&m_superblock)[0 .. Superblock.sizeof]);

        m_groups = new Group[NumGroups];
        ReadBlocks(BlockSize == 1024 ? 2 : 1, (cast(byte *)m_groups.ptr)[0 .. NumGroups * Group.sizeof]);
    }

    ~this() {
        if (m_superblockDirty) {
            m_partition.Write(2, (cast(byte *)&m_superblock)[0 .. Superblock.sizeof]);
        }

        if (m_groupsDirty) {
            ReadBlocks(BlockSize == 1024 ? 2 : 1, (cast(byte *)m_groups.ptr)[0 .. NumGroups * Group.sizeof]);
        }

        delete m_groups;
    }

    override bool Unmount() {
        return true;
    }

    bool LoadContent(DirectoryNode node) {
        Ext2DirectoryNode edir = cast(Ext2DirectoryNode)node;

        if (edir is null)
            return false;

        Inode dirNode = edir.Node.Node;
        byte[] data = new byte[dirNode.SizeLow];
        scope (exit) delete data;

        ReadData(dirNode, data);
        node.IsLoaded = true;

        DirInfo* dirinfo = cast(DirInfo *)data.ptr;
        while (cast(ulong)dirinfo < (cast(ulong)data.ptr + dirNode.SizeLow)) {
            if (!dirinfo.RecordLength)
                return false;

            if(cast(ulong)dirinfo >= cast(ulong)data.ptr + dirNode.SizeLow)
                continue;

            switch (dirinfo.FileType) {
                case DirFileType.File:
                    new Ext2FileNode(dirinfo.Inode, node, FileAttributes(cast(string)dirinfo.Name.ptr[0 .. dirinfo.NameLength].dup));
                    break;
                    
                case DirFileType.Directory:
                    if (dirinfo.Name.ptr[0 .. dirinfo.NameLength] == "." || dirinfo.Name.ptr[0 .. dirinfo.NameLength] == "..")
                        break;
                    
                    new Ext2DirectoryNode(dirinfo.Inode, node, FileAttributes(cast(string)dirinfo.Name.ptr[0 .. dirinfo.NameLength].dup));
                    break;
                    
                case DirFileType.BlockDevice:
                    new Ext2BlockNode(dirinfo.Inode, node, FileAttributes(cast(string)dirinfo.Name.ptr[0 .. dirinfo.NameLength].dup));
                    break;

                case DirFileType.CharDevice:
                    new Ext2CharNode(dirinfo.Inode, node, FileAttributes(cast(string)dirinfo.Name.ptr[0 .. dirinfo.NameLength].dup));
                    break;

                case DirFileType.FIFO:
                    new Ext2PipeNode(dirinfo.Inode, node, FileAttributes("" ~ cast(string)dirinfo.Name.ptr[0 .. dirinfo.NameLength]));
                    break;

                default:
            }

            dirinfo = cast(DirInfo *)(cast(ulong)dirinfo + dirinfo.RecordLength);
        }

        return true;
    }

    package ulong Read(Inode inode, long offset, byte[] data) {
        if (offset > inode.SizeLow)
            return 0;

        ulong length = data.length;
        if (offset + length > inode.SizeLow)
            length = inode.SizeLow - offset;

        ulong startBlock  = offset / BlockSize;
        ulong blockOffset = offset % BlockSize;
        ulong numBlocks   = length / BlockSize;

        if ((length + blockOffset) % BlockSize)
            numBlocks++;

        uint[] blockList = GetBlocks(inode, null);
        byte[] blocks    = new byte[numBlocks * BlockSize];
        scope(exit) delete blockList;
        scope(exit) delete blocks;

        ulong i = startBlock;
        for (int b = 0; i < startBlock + numBlocks && blockList[i]; i++, b += BlockSize)
            ReadBlocks(blockList[i], blocks[b .. b + BlockSize]);

        if (i < startBlock + numBlocks)
            return 0;

        data[] = blocks[blockOffset .. length];

        delete blockList;
        delete blocks;
        return length;
    }

    package ulong Write(Inode inode, long offset, byte[] data) {
        if (offset > inode.SizeLow)
            return 0;
        
        ulong length = data.length;
        if (offset + length > inode.SizeLow)
            length = inode.SizeLow - offset;
        
        ulong startBlock  = offset / BlockSize;
        ulong blockOffset = offset % BlockSize;
        ulong numBlocks   = length / BlockSize;
        
        if ((length + blockOffset) % BlockSize)
            numBlocks++;
        
        uint[] blockList = GetBlocks(inode, null);
        byte[] blocks    = new byte[numBlocks * BlockSize];
        scope(exit) delete blockList;
        scope(exit) delete blocks;

        ReadBlocks(blockList[startBlock], blocks[0 .. blockOffset]);
        blocks[blockOffset .. blockOffset + length] = data[blockOffset .. blockOffset + length];

        ulong i = startBlock;
        for (int b = 0; i < startBlock + numBlocks && blockList[i]; i++, b += BlockSize)
            WriteBlocks(blockList[i], blocks[b .. b + BlockSize]);

        if (i < startBlock + numBlocks)
            return 0;
            
        delete blockList;
        delete blocks;
        return length;
    }

    override FSNode Create(DirectoryNode parent, FileAttributes fileAttributes) {
        int node = Touch((cast(Ext2DirectoryNode)parent).Node, fileAttributes);

        switch (fileAttributes.Type) {
            case FileType.File:
                return new Ext2FileNode(node, parent, fileAttributes);

            case FileType.Directory:
                DiskNode node2 = DiskNode(parent, node);
                Link(node2, (cast(Ext2DirectoryNode)parent).Node, fileAttributes.Name);

                /* Increase link count */
                Inode ino = node2.Node;
                ino.LinkCount++;
                node2.Node = ino;

                /* increase directory count */
                uint group = node2.Number / m_superblock.InodesPerGroup;
                m_groups[group].NumDir++;
                m_groupsDirty = true;

                /* Link . */
                byte[] dBuf = new byte[BlockSize];
                DirInfo* di = cast(DirInfo *)dBuf;
                scope(exit) delete dBuf;

                di.Inode        = node2.Number;
                di.RecordLength = cast(ushort)BlockSize;
                di.Name[0 .. 1] = ".";
                di.NameLength   = 1;
                di.FileType     = DirFileType.Directory;
                Write(node2.Node, 0, dBuf);

                /* Link .. */
                Link((cast(Ext2DirectoryNode)parent).Node, node2, "..");

                return new Ext2DirectoryNode(node2.Number, parent, fileAttributes);

            case FileType.CharDevice:
                return new Ext2CharNode(node, parent, fileAttributes);

            case FileType.BlockDevice:
                return new Ext2BlockNode(node, parent, fileAttributes);

            case FileType.Pipe:
                return new Ext2PipeNode(node, parent, fileAttributes);

            case FileType.SymLink:
                return new Ext2SymLinkNode(node, parent, fileAttributes);

            case FileType.Mountpoint:
                return null;

            case FileType.Socket:
                return new Ext2SocketNode(node, parent, fileAttributes);
               
            default:
                return null;
        }
    }

    override bool Remove(FSNode node) {
        DiskNode diskNode;

        if ((cast(Ext2BlockNode)node) !is null)
            diskNode = (cast(Ext2BlockNode)node).Node;
        else if ((cast(Ext2CharNode)node) !is null)
            diskNode = (cast(Ext2CharNode)node).Node;
        else if ((cast(Ext2DirectoryNode)node) !is null)
            diskNode = (cast(Ext2DirectoryNode)node).Node;
        else if ((cast(Ext2FileNode)node) !is null)
            diskNode = (cast(Ext2FileNode)node).Node;
        else if ((cast(Ext2PipeNode)node) !is null)
            diskNode = (cast(Ext2PipeNode)node).Node;
        else
            return false;

        /* If its not empty dir node */
        if ((cast(Ext2DirectoryNode)node) !is null) {
            if ((cast(DirectoryNode)node).Childrens.Count)
                return false;
        }

        /* its root dir */
        if ((cast(Ext2DirectoryNode)node.Parent) is null)
            return false;

        /* Decrease parent link count */
        auto parent = (cast(Ext2DirectoryNode)node.Parent).Node.Node;
        parent.LinkCount--;
        (cast(Ext2DirectoryNode)node.Parent).Node.Node = parent;

        /* Decrease target link count */
        Inode ino = diskNode.Node;
        ino.LinkCount--;
        diskNode.Node = ino;

        Unlink(diskNode, (cast(Ext2DirectoryNode)node.Parent).Node);

        uint group = diskNode.Number / m_superblock.InodesPerGroup;
        m_groups[group].NumDir--;
        m_groupsDirty = true;

        return true;
    }

    static bool Detect(Partition partition) {
        Superblock sb;
        partition.Read(2, (cast(byte *)&sb)[0 .. Superblock.sizeof]);
        return sb.Signature == 0xEF53;
    }
    
    static IFileSystem Mount(DirectoryNode mountpoint, Partition partition) {
        if (partition is null || mountpoint is null || !mountpoint.IsMountpointable)
            return null;

        if (!Detect(partition))
            return null;

        auto ret                  = new Ext2FileSystem(partition);
        ret.m_rootNode            = new Ext2DirectoryNode(0, null, FileAttributes("/"));
        ret.m_rootNode.FileSystem = ret;
        ret.m_rootNode.m_node     = DiskNode(ret.m_rootNode, 2);

        if (!mountpoint.Mount(ret.m_rootNode)) {
            delete ret;
            return null;
        }
        
        return ret;
    }

    static void Create(Partition partition) {
        //TODO: hook_create
    }

    package FileAttributes GetAttributes(Inode inode) {
        FileAttributes fa = {
            Length: inode.SizeLow,
            UID: inode.UID,
            GID: inode.GID,
            AccessTime: inode.ATime,
            CreateTime: inode.CTime,
            ModifyTime: inode.MTime
        };
        
        if ((inode.Type & InodeType.UR) == InodeType.UR)
            fa.Permissions |= FilePermissions.UserRead;
        if ((inode.Type & InodeType.UW) == InodeType.UW)
            fa.Permissions |= FilePermissions.UserWrite;
        if ((inode.Type & InodeType.UX) == InodeType.UX)
            fa.Permissions |= FilePermissions.UserExecute;
        
        if ((inode.Type & InodeType.GR) == InodeType.GR)
            fa.Permissions |= FilePermissions.GroupRead;
        if ((inode.Type & InodeType.GW) == InodeType.GW)
            fa.Permissions |= FilePermissions.GroupWrite;
        if ((inode.Type & InodeType.GX) == InodeType.GX)
            fa.Permissions |= FilePermissions.GroupExecute;
        
        if ((inode.Type & InodeType.OR) == InodeType.OR)
            fa.Permissions |= FilePermissions.OtherRead;
        if ((inode.Type & InodeType.OW) == InodeType.OW)
            fa.Permissions |= FilePermissions.OtherWrite;
        if ((inode.Type & InodeType.OX) == InodeType.OX)
            fa.Permissions |= FilePermissions.OtherExecute;
        
        return fa;
    }
    
    package void SetAttributes(DiskNode node, FileAttributes fileAttributes) {
//        Inode ino = node.Inode;

        //TODO: just rewrite Inode... easy biznis kamo xDD
        //Jak ale resiznut ten nod?
    }

    package bool ReadInode(ref Inode inode, int number) {
        if (number > m_superblock.NumInodes)
            return false;

        long group  = (number - 1) / m_superblock.InodesPerGroup;
        long offset = (number - 1) % m_superblock.InodesPerGroup;

        long inodeBlock  = (offset * m_superblock.InodeSize) / BlockSize;
        long inodeOffset = (offset * m_superblock.InodeSize) % BlockSize;
        inodeBlock += m_groups[group].InodeTable;

        byte[] buffer = new byte[2 * BlockSize];
        scope(exit) delete buffer;

        if (!ReadBlocks(inodeBlock, buffer))
            return false;

        (cast(byte *)&inode)[0 .. Inode.sizeof] = buffer[inodeOffset .. inodeOffset + Inode.sizeof];
        return true;
    }

    package bool WriteInode(Inode inode, int number) {
        if (number > m_superblock.NumInodes)
            return false;

        long group  = (number - 1) / m_superblock.InodesPerGroup;
        long offset = (number - 1) % m_superblock.InodesPerGroup;

        long inodeBlock  = (offset * m_superblock.InodeSize) / BlockSize;
        long inodeOffset = (offset * m_superblock.InodeSize) % BlockSize;
        inodeBlock += m_groups[group].InodeTable;

        byte[] buffer = new byte[2 * BlockSize];
        scope(exit) delete buffer;

        if (!ReadBlocks(inodeBlock, buffer))
            return false;

        buffer[inodeOffset .. inodeOffset + Inode.sizeof] = (cast(byte *)&inode)[0 .. Inode.sizeof];
        WriteBlocks(inodeBlock, buffer);
        return true;
    }

    private ulong ReadBlocks(long offset, byte[] data) {
        return m_partition.Read(offset * BlockSize / m_partition.BlockSize, data);
    }

    private ulong WriteBlocks(long offset, byte[] data) {
        return m_partition.Write(offset * BlockSize / m_partition.BlockSize, data);
    }

    private ulong ReadGroupBlocks(int group, long offset, byte[] data) {
        if (group > NumGroups)
            return 0;
        
        if (offset + data.length > m_superblock.BlocksPerGroup)
            return 0;
        
        return ReadBlocks(offset + group * m_superblock.BlocksPerGroup, data);
    }

    private ulong WriteGroupBlocks(int group, long offset, byte[] data) {
        if (group > NumGroups)
            return 0;

        if (offset + data.length > m_superblock.BlocksPerGroup)
            return 0;
        
        return WriteBlocks(offset + group * m_superblock.BlocksPerGroup, data);
    }

    private void FreeBlock(uint block) {
        if (!block)
            return;

        uint group = block / m_superblock.BlocksPerGroup;

        byte[] blockBitmap = new byte[BlockSize];
        scope(exit) delete blockBitmap;

        if (!ReadBlocks(m_groups[group].BlockBitmap, blockBitmap))
            return;

        int i = block % m_superblock.BlocksPerGroup - 1;
        blockBitmap[i / 8] &= ~(1 << (i & 7));
        if (!WriteBlocks(m_groups[group].BlockBitmap, blockBitmap))
            return;

        m_groups[group].UnallocatedBlocks++;
        m_groupsDirty = true;
    }

    private uint AllocBlock(uint group) {
        if (group > NumGroups)
            return 0;

        if (!m_groups[group].UnallocatedBlocks)
            for (group = 0; group < NumGroups && !m_groups[group].UnallocatedBlocks; group++) {}

        if (group == NumGroups)
            return 0;

        byte[] blockBitmap = new byte[BlockSize];
        scope(exit) delete blockBitmap;

        if (!ReadBlocks(m_groups[group].BlockBitmap, blockBitmap))
            return 0;

        ulong i = 4 + m_superblock.InodesPerGroup * Inode.sizeof / BlockSize + 1;
        while (blockBitmap[i / 8] & (1 << (i & 7)) && i < m_superblock.BlocksPerGroup)
            i++;

        if (i == m_superblock.BlocksPerGroup)
            return 0;

        blockBitmap[i / 8] |= 1 << (i & 7);
        m_groupsDirty       = true;
        m_superblockDirty   = true;
        m_superblock.NumFreeBlocks--;
        m_groups[group].UnallocatedBlocks--;

        if (!WriteBlocks(m_groups[group].BlockBitmap, blockBitmap))
            return 0;

        return cast(uint)i + m_superblock.BlocksPerGroup * group + 1;
    }

    private uint CountIndirect(ulong size) {
        ulong numBlocks        = size / BlockSize;
        ulong blockPerIndirect = BlockSize / uint.sizeof;
        ulong block            = 12;
        uint ret;

        /* Indirect */
        if (block < numBlocks) {
            ret++;
            block += blockPerIndirect;
        }

        /* Doubly indirect */
        if (block < numBlocks) {
            ret++;
            for (ulong i = 0; i < blockPerIndirect && block < numBlocks; i++) {
                ret++;
                block += blockPerIndirect;
            }
        }

        /* Triply indirect */
        if (block < numBlocks) {
            ret++;
            for (ulong i = 0; i < blockPerIndirect && block < numBlocks; i++) {
                ret++;
                for (ulong j = 0; j < blockPerIndirect && block < numBlocks; j++) {
                    ret++;
                    block += blockPerIndirect;
                }
            }
        }

        return ret;
    }

    private ulong GetIndirect(uint block, int level, uint[] blockList, ulong index, ulong length, uint[] indirects) {
        if (level < 0 || level > 3)
            return 0;
            
        if (!level) {
            blockList[index] = block;
            return 1;
        }

        uint[] blocks = new uint[BlockSize / uint.sizeof];
        scope(exit) delete blocks;

        if (!ReadBlocks(block, (cast(byte *)blocks.ptr)[0 .. BlockSize]))
            return 0;

        if (indirects) {
            indirects[indirects[0]] = block;
            indirects[0]++;
        }

        ulong read;
        for (long i = 0; i < BlockSize / uint.sizeof && index < length; i++) {
            ulong read2 = GetIndirect(blocks[i], level - 1, blockList, index, length, indirects);
            if (!read2)
                return 0;

            index += read2;
            read  += read2;
        }

        return read;
    }

    private ulong SetIndirect(ref uint block, int level, uint[] blockList, ulong index, int group, uint[] indirects) {
        if (level < 0 || level > 3)
            return 0;
        
        if (!level) {
            block = blockList[index];
            return 1;
        }

        uint[] blocks = new uint[BlockSize / uint.sizeof];
        scope(exit) delete blocks;

        if (indirects) {
            block = indirects[indirects[0]];
            indirects[0]++;
        } else
            block = AllocBlock(group);

        ulong totalSetCount;
        for (long i = 0; i < BlockSize / uint.sizeof && blockList[index]; i++) {
            ulong count = SetIndirect(blocks[i], level - 1, blockList, index, group, indirects);
            if (!count)
                return 0;

            index         += count;
            totalSetCount += count;
        }

        if (!WriteBlocks(block, (cast(byte *)blocks.ptr)[0 .. BlockSize]))
            return 0;

        return totalSetCount;
    }

    private uint[] GetBlocks(Inode node, uint[] indirects) {
        int numBlocks    = node.SizeLow / BlockSize + ((node.SizeLow % BlockSize) != 0);
        uint[] blockList = new uint[numBlocks + 1];

        if (indirects)
            indirects[0] = 1;

        int i;
        for (; i < numBlocks && i < 12; i++)
            blockList[i] = node.Direct[i];

        if (i < numBlocks)
            i += GetIndirect(node.Indirect, 1, blockList, i, numBlocks, indirects);
        if (i < numBlocks)
            i += GetIndirect(node.Dindirect, 2, blockList, i, numBlocks, indirects);
        if (i < numBlocks)
            i += GetIndirect(node.Tindirect, 3, blockList, i, numBlocks, indirects);

        blockList[i] = 0;
        return blockList;
    }

    private uint SetBlocks(ref Inode node, uint[] blocks, int group, uint[] indirects) {
        int i;
        for (; i < blocks[i] && i < 12; i++)
            node.Direct[i] = blocks[i];

        if (indirects)
            indirects[0] = 1;
        if (blocks[i])
            i += SetIndirect(node.Indirect, 1, blocks, i, group, indirects);
        if (blocks[i])
            i += SetIndirect(node.Dindirect, 2, blocks, i, group, indirects);
        if (blocks[i])
            i += SetIndirect(node.Tindirect, 3, blocks, i, group, indirects);

        if (blocks[i])
            return 0;

        return i;
    }

    private uint MakeBlocks(ref Inode node, int group) {
        ulong blockNeeded = node.SizeLow / BlockSize;

        if (node.SizeLow % BlockSize)
            blockNeeded++;

        uint[] blocks = new uint[blockNeeded + 1];
        scope(exit) delete blocks;

        uint i;
        for (; i < blockNeeded; i++) {
            node.Direct[i] = AllocBlock(group);
            blocks[i]      = node.Direct[i];

            if (!node.Direct[i])
                break;
        }

        return i; //TODO: test me pls
    }

    private ulong ReadData(Inode node, byte[] data) {
        ulong length     = data.length > node.SizeLow ? node.SizeLow : data.length;
        uint[] blockList = GetBlocks(node, null);
        ulong readcount;

        for (int i = 0; blockList[i]; i++) {
            ulong size = length > BlockSize ? BlockSize : length;
            ReadBlocks(blockList[i], data[readcount .. readcount + size]);
            
            length    -= size;
            readcount += size;
        }

        delete blockList;
        return readcount;
    }

    private void Link(DiskNode node, DiskNode dir, string name) {
        Inode iino = node.Node;
        iino.LinkCount++;
        node.Node = iino;

        Inode dino  = dir.Node;
        byte[] dBuf = new byte[dino.SizeLow + BlockSize];
        DirInfo* di = cast(DirInfo *)dBuf.ptr;
        scope(exit) delete dBuf;
        Read(dino, 0, dBuf);

        /* Find last dir entry */
        DirInfo* next    = di;
        DirInfo* current = di;
        while (cast(ulong)next < (cast(ulong)current + dino.SizeLow)) {
            current = next;
            next    = cast(DirInfo *)(cast(ulong)current + current.RecordLength);
        }

        current.RecordLength = cast(ushort)(cast(ulong)current.Name.ptr + current.NameLength + 1 - cast(ulong)current);
        if (current.RecordLength < 12)
            current.RecordLength = 12;

        current.RecordLength += current.RecordLength % 4 ? 4 - current.RecordLength % 4 : 0;
        next = cast(DirInfo *)(cast(ulong)current + current.RecordLength);

        next.Inode = node.Number;
        next.Name[0 .. name.length] = name[];
        next.NameLength = cast(ubyte)name.length;

        next.FileType = 
            (((iino.Type & InodeType.FIFO)        == InodeType.FIFO)        ? DirFileType.FIFO        : 0) +
            (((iino.Type & InodeType.CharDevice)  == InodeType.CharDevice)  ? DirFileType.CharDevice  : 0) +
            (((iino.Type & InodeType.Directory)   == InodeType.Directory)   ? DirFileType.Directory   : 0) +
            (((iino.Type & InodeType.BlockDevice) == InodeType.BlockDevice) ? DirFileType.BlockDevice : 0) +
            (((iino.Type & InodeType.File)        == InodeType.File)        ? DirFileType.File        : 0) +
            (((iino.Type & InodeType.SymLink)     == InodeType.SymLink)     ? DirFileType.SymLink     : 0) +
            (((iino.Type & InodeType.Socket)      == InodeType.Socket)      ? DirFileType.Socket      : 0);

        next.RecordLength = cast(ushort)(cast(ulong)next.Name.ptr + next.NameLength + 1 - cast(ulong)next);
        if (next.RecordLength < 12)
            next.RecordLength = 12;

        if ((cast(ulong)next + next.RecordLength - cast(ulong)di) > dino.SizeLow) {
            uint[] blocks  = GetBlocks(dino, null);
            uint[] blocks2 = new uint[dino.SizeLow / BlockSize + 1];

            int s = dino.SizeLow / BlockSize;
            blocks2[0 .. s] = blocks[0 .. s];
            blocks2[s]      = AllocBlock(node.Number / m_superblock.InodesPerGroup);
            SetBlocks(dino, blocks2, node.Number / m_superblock.InodesPerGroup, null);

            dino.SizeLow += BlockSize;
            dir.Node      = dino;

            delete blocks;
            delete blocks2;
        }

        next.RecordLength = cast(ushort)(dino.SizeLow - (cast(ulong)next - cast(ulong)di));
        Write(dino, 0, dBuf[0 .. dino.SizeLow]);
    }

    private void Unlink(DiskNode node, DiskNode dir) {
        Inode dino = dir.Node;

        byte[] dBuf = new byte[dino.SizeLow];
        DirInfo* di = cast(DirInfo *)dBuf.ptr;
        scope(exit) delete dBuf;
        ReadData(dino, dBuf);

        DirInfo* p  = di;
        DirInfo* p2 = di;
        int num = node.Number;
        while (num && cast(ulong)p2 < (cast(ulong)di + dino.SizeLow)) {
            p  = p2;
            p2 = cast(DirInfo *)(cast(ulong)p2 + p2.RecordLength);
            num--;
        }

        p.RecordLength += p2.RecordLength;
        Write(dino, 0, dBuf);

        Inode iino = node.Node;
        iino.LinkCount--;

        /* Delete node */
        if (iino.LinkCount < 1) {
            iino.DTime = cast(uint)Time.Now;

            uint indirectNum = CountIndirect(iino.SizeLow);
            uint[] iBlocks   = new uint[indirectNum + 1];
            uint[] blocks    = GetBlocks(iino, iBlocks);

            for (int i = 0; blocks[i]; i++)
                FreeBlock(blocks[i]);

            for (int i = 1; i <= indirectNum; i++)
                FreeBlock(iBlocks[i]);

            delete blocks;
            delete iBlocks;

            uint group = node.Number / m_superblock.InodesPerGroup;
            uint it    = node.Number % m_superblock.InodesPerGroup - 1;
            byte[] ibm = new byte[BlockSize];

            ReadBlocks(m_groups[group].InodeBitmap, ibm);
            ibm[it / 8] &= ~(1 << (it & 7));
            WriteBlocks(m_groups[group].InodeBitmap, ibm);
            
            delete ibm;
            m_groups[group].UnallocatedInodes++;
            m_groupsDirty = true;
        }

        node.Node = iino;
    }

    private int Touch(DiskNode parent, FileAttributes fileAttributes) {
        if (!m_superblock.NumFreeInodes)
            return 0;

        uint blockNeeded    = cast(uint)(fileAttributes.Length / BlockSize);
        uint indirectBlocks = CountIndirect(fileAttributes.Length);
        
        if (fileAttributes.Length % BlockSize)
            blockNeeded++;

        if (m_superblock.NumFreeBlocks < blockNeeded)
            return 0;

        int group = -1;
        for (int i = 0; i < m_groups.length; i++) {
            if (m_groups[i].UnallocatedInodes) {
                if (m_groups[i].UnallocatedBlocks >= blockNeeded) {
                    group = i;
                    break;
                }
            }
        }

        if (group == -1) {
            for (int i = 0; i < m_groups.length; i++) {
                if (m_groups[i].UnallocatedInodes) {
                    group = i;
                    break;
                }
            }
        }

        if (group == -1)
            return 0;

        /* Allocate inode */
        byte[] inodeBitmap = new byte[BlockSize];
        scope(exit) delete inodeBitmap;
        ReadBlocks(m_groups[group].InodeBitmap, inodeBitmap);

        uint inoNum = group == 0 ? m_superblock.FirstInode : 0;
        while (inoNum < m_superblock.InodesPerGroup) {
            if (!(inodeBitmap[inoNum / 8] % (1 << (inoNum & 7))))
                break;

            inoNum++;
        }

        if (inoNum == m_superblock.InodesPerGroup)
            return 0;

        inodeBitmap[inoNum / 8] |= 1 << (inoNum & 7);
        m_groups[group].UnallocatedInodes--;
        m_groupsDirty = true;

        inoNum += m_superblock.InodesPerGroup * group;
        inoNum++;

        Inode* ino = new Inode;
        scope(exit) delete ino;
        ReadInode(*ino, inoNum);

        if (fileAttributes.Type == FileType.Pipe)
            ino.Type = InodeType.FIFO;
        else if (fileAttributes.Type == FileType.CharDevice)
            ino.Type = InodeType.CharDevice;
        else if (fileAttributes.Type == FileType.Directory)
            ino.Type = InodeType.Directory;
        else if (fileAttributes.Type == FileType.BlockDevice)
            ino.Type = InodeType.BlockDevice;
        else if (fileAttributes.Type == FileType.File)
            ino.Type = InodeType.File;
        else if (fileAttributes.Type == FileType.SymLink)
            ino.Type = InodeType.SymLink;
        else if (fileAttributes.Type == FileType.Socket)
            ino.Type = InodeType.Socket;
        else
            ino.Type = 0;
        
        ino.Type              |= fileAttributes.Permissions & 0x1FF; /* 0777 */
        ino.UID                = 0;
        ino.GID                = 0;
        ino.SizeLow            = cast(uint)fileAttributes.Length;
        ino.ATime              = cast(uint)fileAttributes.AccessTime;
        ino.CTime              = cast(uint)fileAttributes.ModifyTime;
        ino.MTime              = cast(uint)fileAttributes.CreateTime;
        ino.LinkCount          = 0;
        ino.DiskSectors        = cast(uint)((blockNeeded + indirectBlocks) * BlockSize / m_partition.BlockSize);
        ino.Flags              = 0;
        ino.OSVal1             = 0;
        ino.Indirect           = 0;
        ino.Dindirect          = 0;
        ino.Tindirect          = 0;
        ino.Generation         = 0;
        ino.ExtendedAttributes = 0;
        ino.SizeHigh           = 0;
        ino.Direct[]           = 0;
        ino.OSVal2[]           = 0;

        uint[] blocks   = new uint[blockNeeded + 1];
        uint[] indirect = new uint[indirectBlocks + 1];
        
        for (int i = 0; i < blockNeeded; i++)
            blocks[i] = AllocBlock(group);

        for (int i = 1; i <= indirectBlocks; i++)
            indirect[i] = AllocBlock(group);

        SetBlocks(*ino, blocks, group, indirect);
        WriteBlocks(m_groups[group].InodeBitmap, inodeBitmap);
        WriteInode(*ino, inoNum);

        return inoNum;
    }
}