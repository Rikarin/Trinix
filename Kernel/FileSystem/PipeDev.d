module Filesystem.PipeDev;

import VFSManager.PipeNode;
import VFSManager.DirectoryNode;
import Devices.Random;
import System.Threading.All;
import System.Collections.Generic.List;
import TaskManager.Thread;
import TaskManager.Task;
import System.DateTime;


class PipeDev : PipeNode {
private:
	List!Thread waitingQueue;
	long refcount;
	Mutex mutex;

	byte[] buffer;
	long writePtr, readPtr;


public:
	this(ulong length, string name = "pipe") { 
		super(name);
		this.length = length;
		atime = ctime = mtime = DateTime.Now;

		waitingQueue = new List!Thread();
		buffer = new byte[length];
		mutex = new Mutex();
	}

	~this() {
		delete waitingQueue;
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

	override ulong Read(ulong offset, byte[] data) {
		ulong collected;

		while (!collected) {
			mutex.WaitOne();
			while (UnreadCount() > 0 && collected < data.length) {
				data[collected++] = buffer[readPtr];
				IncrementRead();
				break;
			}

			mutex.Release();
			Task.Wakeup(waitingQueue);
			if (!collected)
				Task.CurrentThread.Sleep(waitingQueue);
		}

		return collected;
	}

	override ulong Write(ulong offset, byte[] data) {
		ulong written;

		
		while (written < data.length) {
			mutex.WaitOne();
			
			while (FreeSpace() > 0 && written < data.length) {
				buffer[writePtr] = data[written];
				IncrementWrite();
				written++;
			}

			mutex.Release();
			Task.Wakeup(waitingQueue);
			if (written < data.length)
				Task.CurrentThread.Sleep(waitingQueue);

		}

		return written;
	}


private:
	ulong UnreadCount() {
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