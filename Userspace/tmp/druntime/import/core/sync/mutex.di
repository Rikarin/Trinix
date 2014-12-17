// D import file generated from 'src/core/sync/mutex.d'
module core.sync.mutex;
public import core.sync.exception;

version (Windows)
{
	private import core.sys.windows.windows;

}
else
{
	version (Posix)
	{
		private import core.sys.posix.pthread;

	}
	else
	{
		static assert(false, "Platform not supported");
	}
}
class Mutex : Object.Monitor
{
	this();
	this(Object o);
	~this();
	@trusted void lock();
	nothrow @trusted void lock_nothrow();
	private @trusted void lock_impl(Exc)()
	{
		version (Windows)
		{
			EnterCriticalSection(&m_hndl);
		}
		else
		{
			version (Posix)
			{
				int rc = pthread_mutex_lock(&m_hndl);
				if (rc)
					throw new Exc("Unable to lock mutex");
			}

		}

	}

	@trusted void unlock();
	nothrow @trusted void unlock_nothrow();
	private @trusted void unlock_impl(Exc)()
	{
		version (Windows)
		{
			LeaveCriticalSection(&m_hndl);
		}
		else
		{
			version (Posix)
			{
				int rc = pthread_mutex_unlock(&m_hndl);
				if (rc)
					throw new Exc("Unable to unlock mutex");
			}

		}

	}

	bool tryLock();
	private 
	{
		version (Windows)
		{
			CRITICAL_SECTION m_hndl;
		}
		else
		{
			version (Posix)
			{
				pthread_mutex_t m_hndl;
			}
		}
		struct MonitorProxy
		{
			Object.Monitor link;
		}
		MonitorProxy m_proxy;
		package version (Posix)
		{
			pthread_mutex_t* handleAddr();
		}

	}
}
version (unittest)
{
	private import core.thread;

}
