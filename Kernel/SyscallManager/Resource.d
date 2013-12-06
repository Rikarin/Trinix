module SyscallManager.Resource;

import SyscallManager;

import System.IFace;
import System.Threading;
import System.Collections.Generic;


class Resource {
private:
	Mutex lock;
	ulong id, type;
	List!CallTable callTables;


	ulong DoCall(ulong id, ulong[] params) {
		foreach_reverse (x; callTables)
			if (x.id == id)
				return x.CallBack(params);
		
		return ~0UL;
	}


public:
	struct CallTable {
		ulong id;
		ulong delegate(ulong[] params) CallBack;
	}

	@property ulong ResID() { return id; }
	@property ulong ResType() { return type; }


	ulong Call(ulong id, ulong[] params) {		
		if (!id)
			return type;

		//lock.WaitOne();
		ulong ret = DoCall(id, params);
		//lock.Release();
		return ret;
	}


protected:
	this(ulong type, const CallTable[] ct) {
		callTables = new List!CallTable();
		lock = new Mutex();

		this.type = type;
		AddCallTable(ct);
		id = Res.Register(this);
	}

	~this() {
		delete lock;
		delete callTables;
		Res.Unregister(this);
	}

	void AddCallTable(const CallTable[] ct) {
		foreach(x; ct)
			callTables.Add(x);
	}
}