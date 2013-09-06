module SyscallManager.Res;

import System.Collections.Generic.All;
import SyscallManager.Resource;

import System.IFace;
import VFSManager.FSNode;


class Res {
static:
private:
	struct StaticCallTable {
		ulong id;
		ulong function(ulong[] params) CallBack;
	}

	__gshared StaticCallTable[] staticCalls = [
	//	{FNIF_OBJTYPE, &FSNode.SCall}
	];
	
	__gshared List!(Resource) resources;


public:
	bool Init() {
		resources = new List!(Resource)();
		return true;
	}

	void Register(Resource res) {
		resources.Add(res);
	}

	void Unregister(Resource res) {
		resources.Remove(res);
	}

	ulong Call(ulong resource, ulong id, ulong[] params) {
		if (resource == ~1UL) {
			foreach (x; staticCalls) {
				if (x.id == id)
					return x.CallBack(params);
			}
			return ~0UL;
		} else {
			if (resource > resources.Count || resources[resource] is null)
				return ~0UL;
			else
				return resources[resource].Call(id, params);
		}
	}
}