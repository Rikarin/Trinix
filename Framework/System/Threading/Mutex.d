module System.Threading.Mutex;


class Mutex {
	private long locked;


	private long AtomicExchange(long* value) {
		asm {
			naked;
			mov RAX, 1;
			xchg [RSI], RAX;
			ret;
		}
	}

	this() {
		locked = false;
	}

	this(bool initiallyOwned) {
		locked = initiallyOwned;
	}

	void Release() {
		locked = false;
	}

	bool WaitOne() {
		while (AtomicExchange(&locked)) { }
		return true;
	}
}
