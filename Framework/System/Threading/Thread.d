module System.Threaing.Thread;

import System.IFace;
import System.ResourceCaller;


class Thread {
private:
	void delegate() entry;

	static __gshared Thread val;
	static void run() {
		val.entry();
		while (true) { }// todo
	}

public:
	this(void delegate() start) {
		entry = start;
	}

	void Start() {
		//todo mutex
		val = this;
		ResourceCaller.StaticCall(IFace.Thread.OBJECT, [IFace.Thread.S_CREATE, cast(ulong)&run]);
	}
}