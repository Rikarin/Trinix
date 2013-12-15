module FileSystem.Ext2;

import VFSManager;
import System.IO;


class Ext2FileNode : FileNode {
package:
	public ulong inode;


public:
	this(FileSystemProto fileSystem, FileAttributes fileAttributes) {
		super(fileSystem, fileAttributes);
	}
}


class Ext2 : FileSystemProto {
private:
	struct Superblock {
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

		//Extended superblock fields
		uint FirstInode;
		ushort InodeSize;
		ushort SuperblockGroup;
		uint OptionalFeatres;
		uint RequiredFeatures;
		uint ReadWriteFeatures;
		char FSID[16];
		char VolumeName[16];
		char LastPath[64];
		uint Compression;
		ubyte FileStartBlocks;
		ubyte DirStartBlocks;
		private byte unused[2];
		char JournalID[2];
		uint JournalInode;
		uint JournalDevice;
		uint OrphanInodesHead;
	}

	struct Inode {
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
		uint Direct[12];
		uint Indirect;
		uint Dindirect;
		uint Tindirect;
		uint Generation;
		uint ExtendedAttributes;
		uint SizeHigh;
		uint FlagmentBlock;
		uint OSVal2[12];
	}

	struct Group {
	align(1):
		uint BlockBitmap;
		uint InodeBitmap;
		uint InodeTable;
		ushort UnallocatedBlocks;
		ushort UnallocatedInodes;
		ushort NumDir;
		private ushort unused[7];
	}


	Partition part;

	Superblock sb;
	Group[] groups;
	bool groupsDirty;
	bool sbDirty;

	@property uint BlockSize() { return 1024 << sb.BlockSize; }
	@property uint NumGroups() { return (sb.NumInodes / sb.InodesPerGroup) + (sb.NumInodes % sb.InodesPerGroup != 0); }



	this(Partition part) {
		this.part = part;

		part.Read(2, (cast(byte *)&sb)[0 .. Superblock.sizeof]);

		groups = new Group[NumGroups];
		ReadBlocks(1, (cast(byte *)&groups)[0 .. groups.length * Group.sizeof]);
	}

	~this() {

	}

	ulong ReadBlocks(ulong offset, byte[] data) {
		return part.Read(offset * BlockSize / part.BlockSize, data);
	}

	ulong WriteBlocks(ulong offset, byte[] data) {
		return part.Write(offset * BlockSize / part.BlockSize, data);
	}

	ulong ReadGroupBlocks(ulong group, ulong offset, byte[] data) {
		if (group > NumGroups)
			return 0;

		if (offset + data.length > sb.BlocksPerGroup)
			return 0;

		return ReadBlocks(offset + group * sb.BlocksPerGroup, data);
	}

	ulong WriteGroupBlocks(ulong group, ulong offset, byte[] data) {
		if (group > NumGroups)
			return 0;

		if (offset + data.length > sb.BlocksPerGroup)
			return 0;

		return WriteBlocks(offset + group * sb.BlocksPerGroup, data);
	}

	Inode ReadInode(ulong number) {
		if (number > sb.NumInodes)
			return cast(Inode)0;

		ulong group = (number - 1) / sb.InodesPerGroup;
		ulong offset = (number - 1) % sb.InodesPerGroup;

		ulong inoblock = (offset * Inode.sizeof) / BlockSize;
		ulong inooffset = (offset * Inode.sizeof) % BlockSize;
		inoblock += groups[group].InodeTable;

		byte[] buffer = new byte[2 * BlockSize];
		if (!ReadBlocks(inoblock, buffer)) {
			delete buffer;
			return cast(Inode)0;
		}

		Inode ret;
		(cast(byte *)&ret)[0 .. Inode.sizeof] = buffer[inooffset .. Inode.sizeof];
		delete buffer;

		return ret;
	}

	void WriteInode(ulong number, Inode data) {
		if (number > sb.NumInodes)
			return;

		ulong group = (number - 1) / sb.InodesPerGroup;
		ulong offset = (number - 1) % sb.InodesPerGroup;

		ulong inoblock = (offset * Inode.sizeof) / BlockSize;
		ulong inooffset = (offset * Inode.sizeof) % BlockSize;
		inoblock += groups[group].InodeTable;

		byte[] buffer = new byte[2 * BlockSize];
		if (!ReadBlocks(inoblock, buffer)) {
			delete buffer;
			return;
		}

		buffer[inooffset .. Inode.sizeof] = (cast(byte *)&data)[0 .. Inode.sizeof];
		WriteBlocks(inoblock, buffer);
		delete buffer;
	}

	void FreeBlock(ulong block) {
		if (!block)
			return;

		ulong group = block / sb.BlocksPerGroup;

		byte[] blockBitmap = new byte[BlockSize];
		if (!ReadBlocks(groups[group].BlockBitmap, blockBitmap)) {
			delete blockBitmap;
			return;
		}

		ulong i = block % sb.BlocksPerGroup - 1;
		blockBitmap[i / 8] &= ~(1 << (i & 7));
		if (!WriteBlocks(groups[group].BlockBitmap, blockBitmap)) {
			delete blockBitmap;
			return;
		}

		delete blockBitmap;
		groups[group].UnallocatedBlocks++;
		groupsDirty = true;
	}

	ulong AllocBlock(ulong group) {
		if (group > NumGroups)
			return 0;

		if (!groups[group].UnallocatedBlocks)
			for (group = 0; group < NumGroups; group++)
				if (groups[group].UnallocatedBlocks)
					break;

		if (group == NumGroups)
			return 0;

		//Load block bitmap
		byte[] blockBitmap = new byte[BlockSize];
		if (!ReadBlocks(groups[group].BlockBitmap, blockBitmap)) {
			delete blockBitmap;
			return 0;
		}

		//Allocate a block
		ulong i = 4 + sb.InodesPerGroup * Inode.sizeof / BlockSize + 1;
		while (blockBitmap[i / 8] & (1 << (i & 7)) && i < sb.BlocksPerGroup)
			i++;

		if (i == sb.BlocksPerGroup) {
			delete blockBitmap;
			return 0;
		}

		blockBitmap[i / 8] |= 1 << (i & 7);
		groups[group].UnallocatedBlocks--;
		groupsDirty = true;
		sb.NumFreeBlocks--;
		sbDirty = true;
		i++;
		i += sb.BlocksPerGroup * group;

		//write block bitmap
		if (!WriteBlocks(groups[group].BlockBitmap, blockBitmap)) {
			delete blockBitmap;
			return 0;
		}

		return i;
	}

	ulong CountIndirect(ulong size) {
		ulong numBlocks = size / BlockSize;
		ulong blocksPerIndirect = BlockSize / uint.sizeof;
		ulong block = 12;
		ulong ret;

		if (block < numBlocks) {
			ret++;
			block += blocksPerIndirect;
		}

		if (block < numBlocks) {
			ret++;
			for (ulong i = 0; i < blocksPerIndirect && block < numBlocks; i++) {
				ret++;
				block += blocksPerIndirect;
			}
		}

		if (block < numBlocks) {
			ret++;
			for (ulong i = 0; i < blocksPerIndirect && block < numBlocks; i++) {
				ret++;
				for (ulong j = 0; j < blocksPerIndirect && block < numBlocks; j++) {
					ret++;
					block += blocksPerIndirect;
				}
			}
		}

		return ret;
	}

	ulong GetIndirect(ulong block, int level, ulong[] blockList, ulong index, ulong length, ulong[] indirects) {
		if (level > 3)
			return 0;

		if (!level) {
			blockList[index] = block;
			return 1;
		} else {
			ulong i, read;
			byte[] blocks = new byte[BlockSize];
			
			if (!ReadBlocks(block, blocks))
				return 0;

			if (indirects) {
				indirects[indirects[0]] = block;
				indirects[0]++;
			}

			while (i < BlockSize / int.sizeof && index < length) {
				ulong read2 = GetIndirect(blocks[i], level - 1, blockList, index, length, indirects);
				if (!read2)
					return 0;

				index += read2;
				read  += read2;
				i++;
			}

			delete blocks;
			return read;
		}
	}

	ulong SetIndirect(ulong* block, int level, ulong[] blockList, ulong index, ulong group, ulong[] indirects) {
		if (level > 3)
			return 0;

		if (!level) {
			*block = blockList[index];
			return 1;
		} else {
			ulong[] blocks = new ulong[BlockSize / 8];
			ulong i, totalSetCount;

			if (indirects) {
				*block = indirects[indirects[0]];
				indirects[0]++;
			} else
				*block = AllocBlock(group);

			while (i < BlockSize / int.sizeof && blockList[index]) {
				ulong setCount = SetIndirect(&blocks[i], level - 1, blockList, index, group, indirects);
				if (!setCount)
					return 0;

				index += setCount;
				totalSetCount += setCount;
				i++;
			}

			if (!WriteBlocks(*block, (cast(byte *)&blocks)[0 .. blocks.length * 8]))
				return 0;
			
			delete blocks;
			return totalSetCount;
		}
	}

	ulong[] GetBlocks(Inode* node, ulong[] indirects) {
		int numBlocks = node.SizeLow / BlockSize + ((node.SizeLow % BlockSize) != 0);
		ulong[] blockList = new ulong[numBlocks + 1];

		if (indirects)
			indirects[0] = 1;

		int i;
		for (; i < numBlocks && i < 12; i++)
			blockList[i] = node.Direct[i];

		if (i < numBlocks)
			i += GetIndirect(node.Indirect, 1, blockList, i, numBlocks, indirects);
		if (i < numBlocks)
			i += GetIndirect(node.Indirect, 2, blockList, i, numBlocks, indirects);
		if (i < numBlocks)
			i += GetIndirect(node.Indirect, 3, blockList, i, numBlocks, indirects);

		blockList[i] = 0;
		return blockList;
	}

	ulong SetBlocks(Inode* node, ulong[] blocks, int group, ulong[] indirects) {
		int i;
		for (; i < blocks[i] && i < 12; i++)
			node.Direct[i] = cast(uint)blocks[i];

		if (indirects)
			indirects[0] = 1;
		if (blocks[i])
			i += SetIndirect(cast(ulong *)&node.Indirect, 1, blocks, i, group, indirects);
		if (blocks[i])
			i += SetIndirect(cast(ulong *)&node.Dindirect, 2, blocks, i, group, indirects);
		if (blocks[i])
			i += SetIndirect(cast(ulong *)&node.Indirect, 3, blocks, i, group, indirects);

		if (blocks[i])
			return 0;

		return i;
	}	

	ulong MakeBlocks(Inode* node, ulong group) {
		ulong blocksNeeded = node.SizeLow / BlockSize;
		if (node.SizeLow % BlockSize)
			blocksNeeded++;

		ulong[] blockList = new ulong[blocksNeeded + 1];
		for (int i = 0; i < blocksNeeded; i++) {
			node.Direct[i] = cast(uint)AllocBlock(group);
			blockList[i] = node.Direct[i];

			if (!node.Direct[i]) {
				delete blockList;
				return 0;
			}
		}

		return blocksNeeded;
	}

	ulong ReadData(Inode* node, byte[] data) {
		ulong len = data.length > node.SizeLow ? node.SizeLow : data.length;
		ulong[] blockList = GetBlocks(node, null);
		ulong readcount;

		for (int i = 0; blockList[i]; i++) {
			ulong size = len > BlockSize ? BlockSize : len;
			ReadBlocks(blockList[i], data[BlockSize * i .. size]);
			len -= size;
			readcount += size;
		}

		delete blockList;
		return readcount;
	}




	FileAttributes GetStats(ulong inode) {
		Inode node = ReadInode(inode);

		FileAttributes ret;
		ret.Length = node.SizeLow;
		//todo

		assert(0);
	}



public:
	override bool Unmount() { return true; }
	override bool LoadContent(DirectoryNode dir) { return true; }
	override Partition GetPartition() { return part; }
	override FileAttributes GetAttributes(FSNode node) { return node.GetAttributes(); }
	override void SetAttributes(FSNode node, FileAttributes fileAttributes) { node.SetAttributes(fileAttributes); }

	override ulong Write(FileNode file, ulong offset, byte[] data) { return 0; }
	override FSNode Create(DirectoryNode parent, FileType type, FileAttributes fileAttributes) { return null; }
	override bool Remove(DirectoryNode parent, FSNode node) { return false; }


	public static Ext2 Mount(DirectoryNode mountPoint, Partition part) {
		if (mountPoint && !mountPoint.Mountpointable())
			return null;

		auto ret = new Ext2(part);
		ret.isWritable = true;
		ret.rootNode = new DirectoryNode(ret, FSNode.NewAttributes("/"));
		ret.Identifier = "Ext2";

		mountPoint.Mount(ret.rootNode);
		return ret;
	}

	override ulong Read(FileNode file, ulong offset, byte[] data) {
		Inode node;

		if (!ReadBlocks((cast(Ext2FileNode)file).inode, (cast(byte *)&node)[0 .. Inode.sizeof]))
			return 0;

		if (offset > node.SizeLow)
			return 0;

		if (offset + data.length > node.SizeLow)
			return 0;

		ulong startBlock  = offset / BlockSize;
		ulong blockOffset = offset % BlockSize;
		ulong numBlocks   = data.length / BlockSize;

		if ((data.length + blockOffset) % BlockSize)
			numBlocks++;

		ulong[] blockList = GetBlocks(&node, null);
		byte[] blocks = new byte[numBlocks * BlockSize];

		for (int i = 0; i < startBlock + numBlocks && blockList[i]; i++)
			ReadBlocks(blockList[i], blocks[i * numBlocks * BlockSize .. BlockSize]);

		data[] = blocks[blockOffset .. data.length];
		return data.length;
	}
}