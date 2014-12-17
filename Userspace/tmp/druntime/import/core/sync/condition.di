// D import file generated from 'src/core/sync/condition.d'
module core.sync.condition;
public import core.sync.exception;

public import core.sync.mutex;

public import core.time;

version (Windows)
{
	private import core.sync.semaphore;

	private import core.sys.windows.windows;

}
else
{
	version (Posix)
	{
		private import core.sync.config;

		private import core.stdc.errno;

		private import core.sys.posix.pthread;

		private import core.sys.posix.time;

	}
	else
	{
		static assert(false, "Platform not supported");
	}
}
class Condition
{
	this(Mutex m);
	~this();
	@property Mutex mutex();
	void wait();
	bool wait(Duration val);
	void notify();
	void notifyAll();
	private version (Windows)
	{
		bool timedWait(DWORD timeout);
		void notify(bool all);
		HANDLE m_blockLock;
		HANDLE m_blockQueue;
		Mutex m_assocMutex;
		CRITICAL_SECTION m_unblockLock;
		int m_numWaitersGone = 0;
		int m_numWaitersBlocked = 0;
		int m_numWaitersToUnblock = 0;
	}
	else
	{
		version (Posix)
		{
			Mutex m_assocMutex;
			pthread_cond_t m_hndl;
		}
	}

}
version (unittest)
{
	private import core.thread;

	private import core.sync.mutex;

	private import core.sync.semaphore;

	void testNotify();
	void testNotifyAll();
	void testWaitTimeout();
}
