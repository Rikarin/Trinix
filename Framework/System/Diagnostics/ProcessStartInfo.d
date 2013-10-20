module System.Diagnostics.ProcessStartInfo;

import System.IO.Stream;


class ProcessStartInfo {
private:
	string[] args;
	public Stream[] fd;
	string name;
	string desc;


	//for testing modes only
	public long function(ulong*) ThreadEntry;


public:
	@property void Arguments(string value) { args = [value]; }
	@property void Arguments(string[] value) { args[] = value; }
	@property string[] Arguments() { return args; }

	@property void FileDescriptors(Stream value) { fd = [value]; }
	@property void FileDescriptors(Stream[] value) { fd = value; }
	@property Stream[] FileDescriptors() { return fd; }

	@property void FileName(string value) { name = value; }
	@property string FileName() { return name; }

	@property void Description(string value) { desc = value; }
	@property string Description() { return desc; }
}