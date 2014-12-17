// D import file generated from 'src/core/sync/barrier.d'
module core.sync.barrier;
public import core.sync.exception;

private import core.sync.condition;

private import core.sync.mutex;

version (Win32)
{
	private import core.sys.windows.windows;

}
else
{
	version (Posix)
	{
		private import core.stdc.errno;

		private import core.sys.posix.pthread;

	}
}
class Barrier
{
	this(uint limit);
	void wait();
	private 
	{
		Mutex m_lock;
		Condition m_cond;
		uint m_group;
		uint m_limit;
		uint m_count;
	}
}
version (unittest)
{
	private import core.thread;

}
