// D import file generated from 'src/core/sync/rwmutex.d'
module core.sync.rwmutex;
public import core.sync.exception;

private import core.sync.condition;

private import core.sync.mutex;

private import core.memory;

version (Win32)
{
	private import core.sys.windows.windows;

}
else
{
	version (Posix)
	{
		private import core.sys.posix.pthread;

	}
}
class ReadWriteMutex
{
	enum Policy 
	{
		PREFER_READERS,
		PREFER_WRITERS,
	}
	this(Policy policy = Policy.PREFER_WRITERS);
	@property Policy policy();
	@property Reader reader();
	@property Writer writer();
	class Reader : Object.Monitor
	{
		this();
		@trusted void lock();
		@trusted void unlock();
		bool tryLock();
		private 
		{
			@property bool shouldQueueReader();
			struct MonitorProxy
			{
				Object.Monitor link;
			}
			MonitorProxy m_proxy;
		}
	}
	class Writer : Object.Monitor
	{
		this();
		@trusted void lock();
		@trusted void unlock();
		bool tryLock();
		private 
		{
			@property bool shouldQueueWriter();
			struct MonitorProxy
			{
				Object.Monitor link;
			}
			MonitorProxy m_proxy;
		}
	}
	private 
	{
		Policy m_policy;
		Reader m_reader;
		Writer m_writer;
		Mutex m_commonMutex;
		Condition m_readerQueue;
		Condition m_writerQueue;
		int m_numQueuedReaders;
		int m_numActiveReaders;
		int m_numQueuedWriters;
		int m_numActiveWriters;
	}
}
