module SyscallManager.ResourceManager;

import Core;
import Library;
import ObjectManager;
import SyscallManager;

import VFSManager;


struct ResouceCallTable {
	string Identifier;
	long function(long, long, long, long, long) Callback;
}

abstract final class ResourceManager : IStaticModule {
	private __gshared LinkedList!ResouceCallTable _callTables;
	private __gshared List!Resource _resources;

	package static long Register(Resource resource) {
		if (_resources.Contains(resource))
			return -1;

		_resources.Add(resource);
		return _resources.IndexOf(resource);
	}

	package static long Unregister(Resource resource) {
		long index = _resources.IndexOf(resource);

		if (index == -1)
			return -1;

		_resources[index] = null;
		return index;
	}

	static bool Initialize() {
		_callTables = new LinkedList!ResouceCallTable();
		_resources = new List!Resource();

		return true;
	}

	package static long CallResource(long resource, long id, long param1, long param2, long param3, long param4, long param5) {
		scope(exit) Log.WriteJSON("}");

		Log.WriteJSON("syscall", "{");
		Log.WriteJSON("resource", resource);
		Log.WriteJSON("id", id);
		Log.WriteJSON("param1", param1);
		Log.WriteJSON("param2", param2);
		Log.WriteJSON("param3", param3);
		Log.WriteJSON("param4", param4);
		Log.WriteJSON("param5", param5);

		if (resource == 0xFFFFFFFF_FFFFFFFF) {
			ResouceCallTable table = GetCallTable(cast(string)((cast(char *)id)[0 .. param1]));
			if (table is cast(ResouceCallTable)null)
				return -1;

			return table.Callback(param1, param2, param3, param4, param5);
		} else if (resource < _resources.Count && _resources[resource] !is null)
			return _resources[resource].Call(id, param1, param2, param3, param4, param5);

		Log.WriteJSON("value", "Bad call");
		return -1;
	}

	static void AddCallTables(const ResouceCallTable callTable) {
		_callTables.Add(callTable);
	}

	static ResouceCallTable GetCallTable(string identifier) {
		auto table = Array.Find(_callTables, (LinkedListNode!ResouceCallTable o) => o.Value.Identifier == identifier);
		return table !is null ? table.Value : cast(ResouceCallTable)null;
	}
}