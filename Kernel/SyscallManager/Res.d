module SyscallManager.Res;

import Core.Log;
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
		{IFace.FSNode.OBJECT, &FSNode.SCall}
	];
	
	__gshared List!Resource resources;


public:
	bool Init() {
		resources = new List!Resource(0x200);
		return true;
	}

	void Register(Resource res) {
		resources.Add(res);
	}

	void Unregister(Resource res) {
		resources.Remove(res);
	}

	ulong Call(ulong resource, ulong id, ulong[] params) {
		debug (only) {
			import System.Convert;
			Log.PrintSP("\n[Service RES: " ~ Convert.ToString(resource, 16));
			Log.PrintSP(", ID: " ~ Convert.ToString(id, 16));

			foreach (x; params)
				Log.PrintSP(", " ~ Convert.ToString(x, 16));

			Log.PrintSP("]");
		}


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