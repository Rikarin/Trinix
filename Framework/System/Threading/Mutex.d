module System.Threading.Mutex;


class Mutex {
	private __gshared ulong locked;


	private ulong AtomicExchange() {
		asm {
			naked;
			mov RAX, 1;
			xchg RAX, locked;
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
		while (AtomicExchange() == true) { }
		return true;
	}
}
