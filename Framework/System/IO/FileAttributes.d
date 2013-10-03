module System.IO.FileAttributes;


enum FileAttributes : short {
	enum Perms {
		OExecute = 1
		OWrite   = 2,
		ORead    = 4,

		GExecute = 8,
		GWrite   = 16,
		GRead    = 32,

		UExecute = 64,
		UWrite   = 128,
		URead    = 256
	}

	Hidden    = 1,
	Temporary = 2,
}