/**
 * Copyright (c) 2014-2015 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 1.0 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * https://github.com/Bloodmanovski/Trinix and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module SyscallManager.Resource;

import Core;
import Library;
import TaskManager;
import ObjectManager;
import SyscallManager;


abstract class Resource {
    private Mutex m_mutex;
    private LinkedList!(CallTable *) m_callTables;
    private LinkedList!Process m_processes;

    private long m_id;
    private DeviceType m_type;
    private long m_version;
    private string m_identifier;

    protected struct CallTable {
        long ID;
        string Identifier;
        long Params;

        union {
            long delegate() Callback0;
            long delegate(long) Callback1;
            long delegate(long, long) Callback2;
            long delegate(long, long, long) Callback3;
            long delegate(long, long, long, long) Callback4;
            long delegate(long, long, long, long, long) Callback5;
        }
    }

    @property long Handle()           { return m_id;         }
    @property ref DeviceType Type()   { return m_type;       }
    @property ref long Version()      { return m_version;    }
    @property ref string Identifier() { return m_identifier; }

    // Called from ResourceManager
    package long Call(long id, long param1, long param2, long param3, long param4, long param5) {
        switch (id) {
            case 0:
                return m_type;

            case 1:
                (cast(char *)param1)[0 .. m_identifier.length] = m_identifier[0 .. $];
                return param1;

            case 2:
                return m_version;

            case 3:
                long ret;
                foreach_reverse (x; m_callTables) {
                    if (ret == param2)
                        return ret;

                    (cast(char **)param1)[ret++][0 .. x.Value.Identifier.length] = x.Value.Identifier[0 .. $];
                }
                return ret;

            case 4:
                foreach_reverse (x; m_callTables)
                    if ((cast(char *)param1)[0 .. param2] == x.Value.Identifier)
                        return x.Value.ID;
                return -1;

            default:
        }

        m_mutex.WaitOne();
        scope(exit) m_mutex.Release();
            
        if (!m_processes.Contains(Task.CurrentProcess)) {
            Log("Process %d tried to use resource without attaching them first", Task.CurrentProcess.ID);
            return -1;
        }

        foreach_reverse (x; m_callTables) {
            if (x.Value.ID == id) {
                switch (x.Value.Params) {
                    case 0:
                        return x.Value.Callback0();
                    case 1:
                        return x.Value.Callback1(param1);
                    case 2:
                        return x.Value.Callback2(param1, param2);
                    case 3:
                        return x.Value.Callback3(param1, param2, param3);
                    case 4:
                        return x.Value.Callback4(param1, param2, param3, param4);
                    case 5:
                        return x.Value.Callback5(param1, param2, param3, param4, param5);
                    default:
                        return -1;
                }
            }
        }

        return -1;
    }

    protected this(DeviceType type, string identifier, long ver, const CallTable[] callTables) {
        m_callTables = new LinkedList!(CallTable *)();
        m_processes  = new LinkedList!Process();
        m_mutex      = new Mutex();
        m_type       = type;
        m_identifier = identifier;
        m_version    = ver;
        m_id         = ResourceManager.Register(this);

        AddCallTables(callTables);
    }

    protected this(const ModuleDef info, const CallTable[] callTables) {
        m_callTables = new LinkedList!(CallTable *)();
        m_processes  = new LinkedList!Process();
        m_mutex      = new Mutex();
        m_type       = info.Type;
        m_identifier = info.Identifier;
        m_version    = info.Version;
        m_id         = ResourceManager.Register(this);
        
        AddCallTables(callTables);
    }

    protected ~this() {
        delete m_mutex;
        delete m_processes;
        delete m_callTables;

        ResourceManager.Unregister(this);
    }

    /* returns true if process was attached. check for ACL TODO */
    bool AttachProcess(Process process) {
        if (m_processes.Contains(process))
            return false;

        m_processes.Add(process);
        return true;
    }

    /* returns true if we can delete this instance. implement protection against removing FSNodes etc.TODO */
    bool DetachProcess(Process process) {
        m_processes.Remove(process);

        if (!m_processes.Count)
            return true;

        return false;
    }

    protected void AddCallTables(const CallTable[] callTables) {
        foreach (x; callTables)
            if (!m_callTables.Contains(cast(CallTable *)&x))
                m_callTables.Add(cast(CallTable *)&x);
    }
}