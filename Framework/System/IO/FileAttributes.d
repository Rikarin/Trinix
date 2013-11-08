module System.IO.FileAttributes;

import System.DateTime;


enum FileType : ubyte {
	File        = 0x01,
	Directory   = 0x02,
	CharDevice  = 0x04,
	BlockDevice = 0x08,
	Pipe        = 0x10,
	Symlink     = 0x20,
	Mountpoint  = 0x40
}


struct FileAttributes {
	string Name;
	FileType Type;
	ulong Length;
	ulong UID;
	ulong GID;
	ushort Permissions;
	DateTime AccessTime;
	DateTime CreateTime;
	DateTime ModifyTime;
}