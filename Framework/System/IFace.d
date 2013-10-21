module System.IFace;


class IFace {
	enum FSNode : ulong {
		OBJECT = 0x1,

		TYPE = 0x1,
		READ,
		WRITE,
		SFIND,
		SMKDIR,
		GETUID,
		GETGID,
		SETCWD,
		REMOVE,
		SGETRFN,
		SGETCWD,
		GETPERM, //ok FSI
		SETPERM, //ok FSI
		GETPATH, //OK FSI
		GETATIME, //ok FSI
		GETMTIME, //ok FSI
		GETCTIME, //ok FSI
		SETATIME, //ok FSI
		SETMTIME, //ok FSI
		SETCTIME, //ok FSI
		REMOVABLE,
		GETLENGTH,
		GETNCHILD,
		GETIDXCHILD,

		SMKFILE,
		CREATETTY,
	}

	enum Process : ulong {
		OBJECT = 0x2,

		SET_FD = 0x1,
		GET_FD,
		GET_PID, //todo
		CURRENT,
		S_CREATE,
		SEND_SIGNAL,
		SET_HANDLER
	}

	enum Thread : ulong {
		OBJECT = 0x3,

		S_CREATE = 0x1
	}
}

/*
enum : ushort {
	VTIF_OBJTYPE,
	PRIF_OBJTYPE,
	THIF_OBJTYPE,
	FLIF_OBJTYPE,
	FNIF_OBJTYPE,
	SYIF_OBJTYPE
}*/