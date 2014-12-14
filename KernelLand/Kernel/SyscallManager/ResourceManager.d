/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

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

abstract final class ResourceManager {
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