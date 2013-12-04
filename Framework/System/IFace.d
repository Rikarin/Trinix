module System.IFace;


class IFace {
	enum FSNode : ulong {
		OBJECT = 0x1,

		READ = 0x01,
		WRITE,

		RATTRIBUTES,
		WATTRIBUTES,

		SETCWD,
		REMOVE,
		GETPATH, //OK FSI
		GETNCHILD,
		GETIDXCHILD,
	}

	enum VFS : ulong {
		OBJECT = 0x2,

		S_FIND = 0x1,
		S_MK_DIR,
		S_GET_RFN,
		S_GET_CWD,
		S_MK_FILE,
		S_MK_PIPE,
		S_CREATE_TTY,
	}

	enum Process : ulong {
		OBJECT = 0x3,

		SET_FD = 0x1,
		GET_FD,
		CURRENT,
		S_CREATE,
		SEND_SIGNAL,
		SET_HANDLER,
		SWITCH
	}

	enum Thread : ulong {
		OBJECT = 0x4,

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