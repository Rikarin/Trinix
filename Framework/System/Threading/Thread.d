module System.Threaing.Thread;

import System.IFace;
import System.ResourceCaller;


class Thread {
private:
	void function() entry;


public:
	this(void function() start) {
		entry = start;
	}

	void Start() {
		ResourceCaller.StaticCall(IFace.Thread.OBJECT, [IFace.Thread.S_CREATE, cast(ulong)entry]);
	}
}