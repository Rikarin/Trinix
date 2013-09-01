module Filesystem.PipeDev;

import VFS.PipeNode;
import VFS.DirectoryNode;
import Devices.Random;
import System.Threading.All;


class PipeDev : PipeNode {
private:
	long refcount;
	Mutex mutex;

	byte[] buffer;
	long writePtr, readPtr;


public:
	this(ulong length, string name = "pipe") { 
		super(name);
		this.length = length;
		//todo time...

		buffer = new byte[length];
		mutex = new Mutex();
	}

	~this() {
		delete buffer;
		delete mutex;
	}

	override void Open() {
		refcount++;
	}

	override void Close() {
		if (refcount > 0)
			refcount--;
	}

	override long Read(ulong start, out byte[] data) {
		long collected;

		while (!collected) {
			mutex.WaitOne();
			while (UnreadCount() > 0 && collected < data.length) {
				data[collected++] = buffer[readPtr];
				IncrementRead();
			}
			mutex.Release();
		}

		return collected;
	}

	override long Write(ulong start, in byte[] data) {
		long written;

		while (written < data.length) {
			mutex.WaitOne();

			while (FreeSpace() > 0 && written < length) {
				buffer[writePtr] = data[written];
				IncrementWrite();
				written++;
			}
			mutex.Release();
		}

		return written;
	}


private:
	long UnreadCount() {
		if (writePtr == readPtr)
			return 0;

		if (readPtr > writePtr)
			return (length - readPtr) + writePtr;
		else
			return writePtr - readPtr;
	}

	void IncrementRead() {
		readPtr++;
		if (readPtr == length)
			readPtr = 0;
	}

	void IncrementWrite() {
		writePtr++;
		if (writePtr == length)
			writePtr = 0;
	}

	long FreeSpace() {
		if (readPtr == writePtr)
			return length - 1;

		if (readPtr > writePtr)
			return readPtr  - writePtr - 1;
		else
			return (length - writePtr) + readPtr - 1;
	}
}