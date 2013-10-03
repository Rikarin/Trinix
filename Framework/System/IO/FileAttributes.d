module System.IO.FileAttributes;


enum FileAttributes : short {
	OExecute = 1,
	OWrite   = 2,
	ORead    = 4,

	GExecute = 8,
	GWrite   = 16,
	GRead    = 32,

	UExecute = 64,
	UWrite   = 128,
	URead    = 256,


	Hidden    = 512,
	Temporary = 1024,
}