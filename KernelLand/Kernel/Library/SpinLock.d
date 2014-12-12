module Library.SpinLock;

import TaskManager;


class SpinLock {
	private long _locked;

	private long AtomicExchange(long* value) {
		long ret = 1;

		asm {
			"xchg %0, [%2]" : "=a"(ret) : "a"(1), "r"(value);
		}

		return ret;
	}

	this() {
		_locked = false;
	}

	this(bool initiallyOwned) {
		_locked = initiallyOwned;
	}

	bool WaitOne() {
		while (AtomicExchange(&_locked)) {}
		return true;
	}

	void Release() {
		_locked = false;
	}

	@property bool IsLocked() {
		return _locked != 0;
	}
}