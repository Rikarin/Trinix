module FileSystem.Ext2;

import VFSManager.Partition;


class Ext2 {
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
		uint BlockBitmap;
		uint InodeBitmap;
		uint InodeTable;
		ushort UnallocatedBlocks;
		ushort UnallocatedInodes;
		ushort NumDir;
		private ushort unused[7];
	}


	enum BLOCK_SIZE = 0x123; //todo
	Partition part;

	Superblock sb;
	Group[] groups;
	bool groupsDirty;
	bool sbDirty;

	@property ulong BlockSize() { return 0; } //todo
	@property ulong NumGroups() { return 0; }


	ulong ReadBlocks(ulong offset, byte[] data) {
		return part.Read(offset * BlockSize / BLOCK_SIZE, data);
	}

	ulong WriteBlocks(ulong offset, byte[] data) {
		return part.Write(offset * BlockSize / BLOCK_SIZE, data);
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
		if (gorup > NumGroups)
			return 0;

		if (!groups[group].UnallocatedBlocks)
			for (group = 0; group < NumGroups; group++)
				if (groups[group].UnallocatedBlocks)
					break;

		if (group == NumBlocks)
			return 0;

		//Load block bitmap
		byte[] blockBitmap = new byte[BlockSize];
		if (!ReadBlocks(groups[group].BlockBitmap, blockBitmap)) {
			delete blockBitmap;
			return;
		}

		//Allocate a block
		ulong i = 4 + sb.InodesPerGroup * Inode.sizeof / BlockSize + 1;
		while (blockBitmap[i / 8] & (1 << (i & 7)) && i < sb.BlocksPerGroup)
			i++;

		if (i == sb.BlocksPerGroup) {
			delete bitmap;
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
			return;
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

	//ulong GetIndirect(ulong block, int level, )
}