/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module ObjectManager.ResourceManager;

import Core;
import Library;
import VFSManager;
import ObjectManager;

import System.Runtime;


alias long function(long, long, long, long, long) StaticSyscallCallback;

/**
 * This static class is a manager for every instance of Resource class.
 * ResourceManager is called by internal library.
 * 
 */
abstract final class ResourceManager {
    private __gshared Dictionary!(string, StaticSyscallCallback) m_callTables;
    private __gshared List!Resource m_resources;

    /**
     * Register a instance of Resource class to ResourceManager.
     * This method should be called only from Rescource constructor!
     * 
     * Params:
     *      resource    =       instance of resource
     * 
     * Returns:
     *      -1                  when duplication was found
     *      unique id for every register Resource
     */
    package static long Register(Resource resource) {
        if (m_resources.Contains(resource))
            return -1;

        m_resources.Add(resource);
        return m_resources.IndexOf(resource);
    }

    /**
     * Remove a registred Resource object from ResourceManager
     * 
     * Params:
     *      resource    =       instance of resource
     * 
     * Returns:
     *      true when object was removed successfuly
     */
    package static bool Unregister(Resource resource) {
        long index = m_resources.IndexOf(resource);

        if (index == -1)
            return false;

        m_resources[index] = null;
        return true;
    }

    /**
     * This is a 'static constructor' called by Main in initialization state
     * 
     * Returns:
     *      true when initialization was successful
     */
    static void Initialize() {
        m_callTables = new Dictionary!(string, StaticSyscallCallback)();
        m_resources  = new List!Resource();
    }

    static void Finalize() {
        delete m_callTables;
        delete m_resources;
    }

    /**
     * This is called only by internal library
     * 
     * Params:
     *      resource    =       id of resource or ~0UL when is called static
     *                          call table
     *      id          =       param of resource or id of static call entry
     *      param1      =       TODO
     *      param2      =       TODO
     *      param3      =       TODO
     *      param4      =       TODO
     *      param5      =       TODO
     *
     * TODO:
     *      o Add package(Architecture)
     */
    static long CallResource(long resource, long id, long param1, long param2, long param3, long param4, long param5) {
        Log("Syscall ===>");
        Log(" - Resource = %16x | ID = %16x", resource, id);
        Log(" - Param1 = %16x   | Param2 = %16x", param1, param2);
        Log(" - Param3 = %16x   | Param4 = %16x", param3, param4);
        Log(" - Param5 = %16x", param5);
        Log("");

        if (resource == 0xFFFFFFFF_FFFFFFFF) {
            auto callback = m_callTables[(cast(const char *)id).ToString()];
            if (callback is null)
                return SyscallReturn.Error;

            return callback(param1, param2, param3, param4, param5);
        } else if (resource < m_resources.Count && m_resources[resource] !is null)
            return m_resources[resource].Call(id, param1, param2, param3, param4, param5);

        Log("Error: Bad call");
        return SyscallReturn.Error;
    }

    static void AddCallTable(string identifier, StaticSyscallCallback callback) {
        m_callTables[identifier] = callback;
    }

    static bool RemoveCallTable(string identifier) {
        return m_callTables.Remove(identifier);
    }
}