module SyscallManager.Resource;

import System.Threading.All;
import System.Collections.Generic.All;
import SyscallManager.Res;


class Resource {
public:
	struct CallTable {
		ulong id;
		ulong delegate(ulong[] params) CallBack;
	}

	@property ulong ResID() { return id; }
	@property ulong ResType() { return type; }


	ulong Call(ulong id, ulong[] params) {
		if (!Accesible())
			return ~0UL;

		if (!id)
			return type;

		lock.WaitOne();
		ulong ret = DoCall(id, params);
		lock.Release();
		return ret;
	}


private:
	Mutex lock;
	ulong id, type;
	List!(CallTable) callTables;


	ulong DoCall(ulong id, ulong[] params) {
		foreach (x; callTables) { //TODO: reverse foreach
			if (x.id == id)
				return x.CallBack(params);
		}
		
		return ~0UL;
	}


protected:
	abstract bool Accesible();

	this(ulong type, const CallTable[] ct) {
		callTables = new List!(CallTable)();
		lock = new Mutex();

		this.type = type;
		AddCallTable(ct);
		id = Res.Register(this);
	}

	~this() {
		delete lock;
		Res.Unregister(this);
	}

	void AddCallTable(const CallTable[] ct) {
		foreach(x; ct)
			callTables.Add(x);
	}
}