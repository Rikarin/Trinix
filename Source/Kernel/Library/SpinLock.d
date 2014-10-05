module Library.SpinLock;

import TaskManager;


public class SpinLock {
	private long _locked;

	private long AtomicExchange(long* value) {
		long ret = 1;

		asm {
			"xchg %0, [%2]" : "=a"(ret) : "a"(1), "r"(value);
		}

		return ret;
	}

	public this() {
		_locked = false;
	}

	public this(bool initiallyOwned) {
		_locked = initiallyOwned;
	}

	public bool WaitOne() {
		while (AtomicExchange(&_locked)) {}
		return true;
	}

	public void Release() {
		_locked = false;
	}

	@property public bool IsLocked() {
		return _locked != 0;
	}
}