module System.Threading.Thread;

import System.IFace;
import System.ResourceCaller;


class Thread {
private:
	void delegate() entry;

	static __gshared Thread val;
	static void run() {
		val.entry();
	}

public:
	this(void delegate() start) {
		entry = start;
	}

	void Start() {
		//todo mutex
		ulong[2] tmp = [IFace.Thread.S_CREATE, cast(ulong)&run];
		val = this;
		ResourceCaller.StaticCall(IFace.Thread.OBJECT, tmp);
	}
}