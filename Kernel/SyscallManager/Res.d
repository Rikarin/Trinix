module SyscallManager.Res;

import Core.Log;
import SyscallManager.Resource;

import System.IFace;
import VFSManager.FSNode;

import System.Collections.Generic.List;

class Res {
static:
private:
	struct StaticCallTable {
		ulong id;
		ulong function(ulong[] params) CallBack;
	}

	__gshared StaticCallTable[3] staticCalls;
	__gshared List!Resource resources;


package:
	ulong Register(Resource res) {
		resources.Add(res);
		return resources.IndexOf(res);
	}

	void Unregister(Resource res) {
		resources.Remove(res);
	}


public:
	bool Init() {
		resources = new List!Resource(0x200); //TODO: FIXME PLZ
		resources.Add(new NullRes()); //mask index 0
		
		import TaskManager.Process; //TODO FIX THIS FUCKIN HACK
		import TaskManager.Thread; //THIS TOO
		StaticCallTable aa = {IFace.FSNode.OBJECT, &FSNode.SCall};
		staticCalls[0] = aa;
		StaticCallTable ab = {IFace.Process.OBJECT, &Process.SCall};
		staticCalls[1] = ab;
		StaticCallTable ac = {IFace.Thread.OBJECT, &Thread.SCall};
		staticCalls[2] = ac;

		return true;
	}

	Resource GetByID(ulong id, ulong type) {
		if (id >= resources.Count)
			return null;

		if (resources[id].ResType != type)
			return null;

		return resources[id];
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


package class NullRes : Resource {
	this() { super(0, null); }
	override bool Accessible() { return false; }
}