module VFSManager.FileAttributes;


enum FileType {
	File        = 0x01,
	Directory   = 0x02,
	CharDevice  = 0x04,
	BlockDevice = 0x08,
	Pipe        = 0x10,
	SymLink     = 0x20,
	Mountpoint  = 0x40,
	Socket      = 0x80
}


enum FilePermissions {
	OtherExecute = 1,
	OtherWrite   = 2,
	OtherRead    = 4,
	GroupExecute = 8,
	GroupWrite   = 16,
	GroupRead    = 32,
	UserExecute  = 64,
	UserWrite    = 128,
	UserRead     = 256
}


struct FileAttributes {
	string Name;
	FileType Type;
	ulong Length;
	ulong UID;
	ulong GID;
	FilePermissions Permissions;
	ulong AccessTime;
	ulong CreateTime;
	ulong ModifyTime;
}