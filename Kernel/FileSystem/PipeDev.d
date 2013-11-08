module FileSystem.PipeDev;

import VFSManager.PipeNode;
import VFSManager.DirectoryNode;
import Devices.Random;
import TaskManager.Thread;
import TaskManager.Task;

import System.DateTime;
import System.Threading.All;
import System.IO.FileAttributes;
import System.Collections.Generic.List;


class PipeDev : PipeNode {
private:
	List!Thread waitingQueue;
	Mutex mutex;
	byte[] buffer;

	long writePtr, readPtr;


public:
	override FileAttributes GetAttributes() {
		attribs.Length = UnreadCount();
		return attribs;
	}

	this(string name, ulong length) { 
		super(NewAttributes(name));

		waitingQueue = new List!Thread();
		buffer = new byte[length];
		mutex = new Mutex();
	}

	~this() {
		delete waitingQueue;
		delete buffer;
		delete mutex;
	}

	override ulong Read(ulong offset, byte[] data) {
		ulong collected;

		while (!collected) {
			mutex.WaitOne();
			while (UnreadCount() > 0 && collected < data.length) {
				data[collected++] = buffer[readPtr];
				IncrementRead();
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
			return (buffer.length - readPtr) + writePtr;
		else
			return writePtr - readPtr;
	}

	void IncrementRead() {
		readPtr++;
		if (readPtr == buffer.length)
			readPtr = 0;
	}

	void IncrementWrite() {
		writePtr++;
		if (writePtr == buffer.length)
			writePtr = 0;
	}

	long FreeSpace() {
		if (readPtr == writePtr)
			return buffer.length - 1;

		if (readPtr > writePtr)
			return readPtr  - writePtr - 1;
		else
			return (buffer.length - writePtr) + readPtr - 1;
	}
}