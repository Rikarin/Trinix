/**
 * Copyright (c) 2014-2015 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 1.0 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * https://github.com/Bloodmanovski/Trinix and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module Modules.Filesystem.Ext2.Ext2Filesystem;

import Core;
import Library;
import VFSManager;
import ObjectManager;
import Modules.Filesystem.Ext2;


final class Ext2Filesystem : IFileSystem {
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

    @property uint BlockSize() {
        return 1024 << m_superblock.BlockSize;
    }

    @property uint NumGroups() {
        return (m_superblock.NumInodes / m_superblock.InodesPerGroup) + (m_superblock.NumInodes % m_superblock.InodesPerGroup != 0);
    }

    @property override Partition GetPartition() {
        return m_partition;
    }

    @property bool IsWritable() {
        return true;
    }

    @property DirectoryNode RootNode() {
        return m_rootNode;
    }

    private this(Partition partition) {
        m_partition = partition;
        m_partition.Read(2, (cast(byte *)&m_superblock)[0 .. Superblock.sizeof]);

        m_groups = new Group[NumGroups];
        ReadBlocks(BlockSize == 1024 ? 2 : 1, (cast(byte *)m_groups.ptr)[0 .. NumGroups * Group.sizeof]);
    }

    ~this() {

        //TODO: hook_close
        delete m_groups;
    }

    override bool Unmount() {
        return true;
    }

    bool LoadContent(DirectoryNode node) {
        Ext2DirectoryNode edir = cast(Ext2DirectoryNode)node;

        if (edir is null)
            return false;

        Inode dirNode = edir.Inode;
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
                    new Ext2FileNode(dirinfo.Inode, node, FSNode.NewAttributes(cast(string)dirinfo.Name.ptr[0 .. dirinfo.NameLength].dup));
                    break;
                    
                case DirFileType.Directory:
                    if (dirinfo.Name.ptr[0 .. dirinfo.NameLength] == "." || dirinfo.Name.ptr[0 .. dirinfo.NameLength] == "..")
                        break;
                    
                    new Ext2DirectoryNode(dirinfo.Inode, node, FSNode.NewAttributes(cast(string)dirinfo.Name.ptr[0 .. dirinfo.NameLength].dup));
                    break;
                    
                case DirFileType.BlockDevice:
                    new Ext2BlockNode(dirinfo.Inode, node, FSNode.NewAttributes(cast(string)dirinfo.Name.ptr[0 .. dirinfo.NameLength].dup));
                    break;

                case DirFileType.CharDevice:
                    new Ext2CharNode(dirinfo.Inode, node, FSNode.NewAttributes(cast(string)dirinfo.Name.ptr[0 .. dirinfo.NameLength].dup));
                    break;

                case DirFileType.FIFO:
                    new Ext2PipeNode(dirinfo.Inode, node, FSNode.NewAttributes("" ~ cast(string)dirinfo.Name.ptr[0 .. dirinfo.NameLength]));
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


    //TODO: implement Socket and Symlink

    //TODO: pridat jeste InodeNumber() do vsech nodu...
    //why?


    override FSNode Create(DirectoryNode parent, FileAttributes fileAttributes) {
        //ext2_mkdir
        //TODO: ext2_touch

        return null; 
    }

    override bool Remove(FSNode node) { //ext2_rmdir
    /*    Inode* inode;

        if ((cast(Ext2BlockNode)node) !is null)
            inode = (cast(Ext2BlockNode)node).m_inode;
        else if ((cast(Ext2CharNode)node) !is null)
            inode = (cast(Ext2CharNode)node).m_inode;
        else if ((cast(Ext2DirectoryNode)node) !is null)
            inode = (cast(Ext2DirectoryNode)node).m_inode;
        else if ((cast(Ext2FileNode)node) !is null)
            inode = (cast(Ext2FileNode)node).m_inode;
        else if ((cast(Ext2PipeNode)node) !is null)
            inode = (cast(Ext2PipeNode)node).m_inode;
        else
            return false;

        if ((cast(Ext2DirectoryNode)node) !is null) {
            if ((cast(DirectoryNode)node).Childrens.Count)
                return false;
        }

        if ((cast(Ext2DirectoryNode)node.Parent) is null)
            return false;
*/
        /* Decrease parent link count */
        auto parent = (cast(Ext2DirectoryNode)node.Parent).Inode;
        parent.LinkCount--;
        (cast(Ext2DirectoryNode)node.Parent).Inode = parent;

        /* Decrease target link count */
        //auto target = 

        //TODO

        //Inode n;

        //uint group = 

        return false; //TODO: ext2_rmdir
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

        auto ret                  = new Ext2Filesystem(partition);
        ret.m_rootNode            = new Ext2DirectoryNode(0, null, FSNode.NewAttributes("/"));
        ret.m_rootNode.FileSystem = ret;
        ret.m_rootNode.m_inode    = 2;

        if (!mountpoint.Mount(ret.m_rootNode)) {
            delete ret;
            return null;
        }
        
        return ret;
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
    
    package void SetAttributes(int num, FileAttributes fileAttributes) {
        //TODO: do this via touch??
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

    private ulong CountIndirect(ulong size) {
        ulong numBlocks        = size / BlockSize;
        ulong blockPerIndirect = BlockSize / uint.sizeof;
        ulong block            = 12;
        ulong ret;

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

    private uint[] GetBlocks(ref Inode node, uint[] indirects) {
        int numBlocks = node.SizeLow / BlockSize + ((node.SizeLow % BlockSize) != 0);
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

    private int Link(ref Inode node, ref Inode dir, string name) {
        return 42; //TODO
    }

    private int Unlink(ref Inode node, ref Inode dir) {
        return 42;//TODO
    }
}