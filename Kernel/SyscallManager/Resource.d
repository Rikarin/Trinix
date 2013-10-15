module SyscallManager.Resource;

import System.Threading.All;
import System.Collections.Generic.List;
import SyscallManager.Res;
import System.IFace;


class Resource {
private:
	Mutex lock;
	ulong id, type;
	List!(CallTable) callTables;


	ulong DoCall(ulong id, ulong[] params) {
		//foreach (x; callTables) { //TODO: reverse foreach. NEED have to fixed foreach for list
		for (long i = 0; i < callTables.Count; i++) {
			if (callTables[i].id == id)
				return callTables[i].CallBack(params);
		}
		
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
		if (!Accessible())
			return ~0UL;

		if (!id)
			return type;

		lock.WaitOne();
		ulong ret = DoCall(id, params);
		lock.Release();
		return ret;
	}


protected:
	abstract bool Accessible();

	this(ulong type, const CallTable[] ct) {
		callTables = new List!(CallTable)();
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