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


/**
 * Definition of static call table
 * 
 * Identifier is a unique string where is defined full path to
 * registred class like com.trinix.VFSManager.FSNode where com is predefined
 * constant, trinix/modules defines if class is part of kernel or module,
 * VFSManager is part of package's name and FSNode is name of class
 * 
 * Callback is a callback defined in each class providing statc syscall
 */
struct ResouceCallTable {
	string Identifier;
	long function(long, long, long, long, long) Callback;
}

/**
 * This static class is a manager for every instance of Resource class.
 * ResourceManager is called by SyscallManager or by internal library.
 * 
 */
abstract final class ResourceManager {
	private __gshared LinkedList!ResouceCallTable _callTables;
	private __gshared List!Resource _resources;

	/**
	 * Register a instance of Resource class to ResourceManager.
	 * This method should be called only from Rescource constructor!
	 * 
	 * Params:
	 * 		resource	=		instance of resource
	 * 
	 * Returns:
	 * 		-1					when duplication was found
	 * 		unique id for every register Resource
	 */
	package static long Register(Resource resource) {
		if (_resources.Contains(resource))
			return -1;

		_resources.Add(resource);
		return _resources.IndexOf(resource);
	}

	/**
	 * Remove a registred Resource object from ResourceManager
	 * 
	 * Params:
	 * 		resource	=		instance of resource
	 * 
	 * Returns:
	 * 		true when object was removed successfuly
	 */
	package static bool Unregister(Resource resource) {
		long index = _resources.IndexOf(resource);

		if (index == -1)
			return false;

		_resources[index] = null;
		return true;
	}

	/**
	 * This is a 'static constructor' called by Main in initialization state
	 * 
	 * Returns:
	 * 		true when initialization was successful
	 */
	static void Initialize() {
		_callTables = new LinkedList!ResouceCallTable();
		_resources  = new List!Resource();
	}

    static void Finalize() {
        delete _callTables;
        delete _resources;
    }

	/**
	 * This is called only by SyscallManager or by internal library
	 * 
	 * Params:
	 * 		resource	=		id of resource or ~0UL when is called static
	 * 							call table
	 * 		id			=		param of resource or id of static call entry
	 * TODO
	 */
	package static long CallResource(long resource, long id, long param1, long param2, long param3, long param4, long param5) {
        Log("Syscall ===>");
        Log(" - Resource = %16x | ID = %16x", resource, id);
        Log(" - Param1 = %16x   | Param2 = %16x | Param3 = %16x", param1, param2, param3);
        Log(" - Param4 = %16x   | Param5 = %16x", param4, param5);

		if (resource == 0xFFFFFFFF_FFFFFFFF) {
			ResouceCallTable table = GetCallTable(cast(string)((cast(char *)id)[0 .. param1]));
			if (table is cast(ResouceCallTable)null)
				return -1;

			return table.Callback(param1, param2, param3, param4, param5);
		} else if (resource < _resources.Count && _resources[resource] !is null)
			return _resources[resource].Call(id, param1, param2, param3, param4, param5);

        Log("Error: Bad call");
		return -1;
	}

	static bool AddCallTable(const ResouceCallTable callTable) {
		if (_callTables.Contains(callTable))
			return false;

		_callTables.Add(callTable);
		return true;
	}

	static bool RemoveCallTable(const ResouceCallTable callTable) {
		if (!_callTables.Contains(callTable))
			return false;

		_callTables.Remove(callTable);
		return true;
	}

	static ResouceCallTable GetCallTable(string identifier) {
		auto table = Array.Find(_callTables, (LinkedListNode!ResouceCallTable o) => o.Value.Identifier == identifier);
		return table !is null ? table.Value : cast(ResouceCallTable)null;
	}
}