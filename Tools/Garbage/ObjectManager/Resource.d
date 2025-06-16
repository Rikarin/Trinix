﻿/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module ObjectManager.Resource;

import Core;
import Library;
import TaskManager;
import Architecture;
import ObjectManager;

import System.Runtime;


abstract class Resource {
   // private Mutex m_mutex; //TODO: need i this??
    private LinkedList!CallTable m_callTables;
    private LinkedList!Process m_processes;

    private long m_id;
    private string m_name;
    private DeviceType m_type;
    private long m_version;
    private string m_identifier;

    protected struct CallTable {
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

        private long ID;
    }

    @property {
        string Name()           { return m_name;       }
        long Handle()           { return m_id;         }
        ref long Version()      { return m_version;    }
        ref DeviceType Type()   { return m_type;       }
        ref string Identifier() { return m_identifier; }

        bool Name(string value) {
            //TODO: check if name already exists in ResourceManager.m_resources;

            delete m_name;
            m_name = value.dup;
            return true;
        }
    }

    private this() {
        m_callTables = new LinkedList!CallTable();
        m_processes  = new LinkedList!Process();
        //m_mutex      = new Mutex();
        m_id         = ResourceManager.Register(this);
    }

    protected this(DeviceType type, string identifier, long ver, const CallTable[] callTables) {
        m_type       = type;
        m_identifier = identifier;
        m_version    = ver;

        this();
        AddCallTables(callTables);
    }

    protected this(const ModuleDef info, const CallTable[] callTables) {
        m_type       = info.Type;
        m_identifier = info.Identifier;
        m_version    = info.Version;
        
        this();
        AddCallTables(callTables);
    }

    protected ~this() {
       // delete m_mutex;
        delete m_processes;
        delete m_callTables;
        delete m_name;

        ResourceManager.Unregister(this);
    }

    /* returns true if process was attached. check for ACL TODO */
    /*TODO: package(TaskManager.Process)*/
    bool AttachProcess(Process process) {
        if (m_processes.Contains(process))
            return false;

        m_processes.Add(process);
        return true;
    }

    /* returns true if we can delete this instance. implement protection against removing FSNodes etc.TODO */
    /* TODO: package(TaskManager.Process)*/
    bool DetachProcess(Process process) {
        m_processes.Remove(process);

        if (!m_processes.Count)
            return true;

        return false;
    }

    protected void AddCallTables(const CallTable[] callTables) {
        long highestID = SyscallType.Call;

        foreach (x; m_callTables) {
            if (x.Value.ID > highestID)
                highestID = x.Value.ID;
        }

        foreach (x; callTables) {
            CallTable c = x;
            c.ID = highestID++;
            m_callTables.Add(c);
        }
    }

    static bool IsValidAddress(long address) {
        if (!address)
            return false;

        if (address >= LinkerScript.KernelBase)
            return false;

        return true;
    }

    package long Call(long id, long param1, long param2, long param3, long param4, long param5) {
        switch (cast(SyscallType)id) {
            case SyscallType.Type:
                return m_type;

            case SyscallType.Identifier:
                (cast(char *)param1)[0 .. m_identifier.length] = m_identifier[0 .. $];
                return m_identifier.length;

            case SyscallType.Version:
                return m_version;

            case SyscallType.Lookup:
                long ret;
                foreach_reverse (x; m_callTables) {
                    if (ret == param2)
                        return ret;

                    (cast(char **)param1)[ret++][0 .. x.Value.Identifier.length] = x.Value.Identifier[0 .. $];
                }
                return ret;

            case SyscallType.Translate:
                foreach_reverse (x; m_callTables)
                    if ((cast(char *)param1)[0 .. param2] == x.Value.Identifier)
                        return x.Value.ID;
                return SyscallReturn.Error;

            case SyscallType.Close:
                if (Process.Current.DetachResource(this))
                    return 1;
                return 0;

            default:
        }

     //   m_mutex.WaitOne();
     //   scope(exit) m_mutex.Release();

        if (!m_processes.Contains(Process.Current)) {
            Log("Process %d tried to use resource without attaching them first", Process.Current.ID);
            return SyscallReturn.Error;
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
                        //TODO: ERROR, bad param num in calltable??
                        return SyscallReturn.Error;
                }
            }
        }

        return SyscallReturn.Error;
    }
}