module SyscallManager.ResourceManager;

import Core;
import Library;
import ObjectManager;
import SyscallManager;

import VFSManager;


public abstract final class ResourceManager : IStaticModule {
	private __gshared List!Resource _resources;

	private __gshared const long function(long, long, long, long, long)[] _staticCalls = [
		&FSNode.StaticCallback
	];

	package static long Register(Resource resource) {
		if (_resources.IndexOf(resource) != -1)
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

	public static bool Initialize() {
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

		if (resource == 0xFFFFFFFF_FFFFFFFF && id < _staticCalls.length)
			return _staticCalls[id](param1, param2, param3, param4, param5);
		else if (resource < _resources.Count && _resources[resource] !is null)
			return _resources[resource].Call(id, param1, param2, param3, param4, param5);

		Log.WriteJSON("value", "Bad call");
		return -1;
	}
}