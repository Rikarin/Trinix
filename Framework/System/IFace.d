module System.IFace;


class IFace {
	enum FSNode : ulong {
		OBJECT = 0x1,

		READ = 0x01,
		WRITE,
		SFIND,
		SMKDIR,

		RSTATS,
		WSTATS,

		SETCWD,
		REMOVE,
		SGETRFN,
		SGETCWD,
		GETPATH, //OK FSI
		REMOVABLE,
		GETNCHILD,
		GETIDXCHILD,

		SMKFILE,
		CREATETTY,
		SMKPIPE,
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