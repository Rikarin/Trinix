﻿/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module TaskManager.Process;

import Core;
import Library;
import VFSManager;
import TaskManager;
import Architecture;
import MemoryManager;
import ObjectManager;


final class Process : Resource {
    private enum IDENTIFIER = "com.trinix.TaskManager.Process";
    private v_addr m_userStack = 0xFFFFFFFF_80000000;

    private ulong m_id;
    private ulong m_uid;
    private ulong m_gid;
    private bool m_isKernel;

    package Paging m_paging;
    private DirectoryNode m_cwd;

    private LinkedList!Thread m_threads;
    private List!Resource m_resources; //TODO: look on this

    @property {
        static auto Current()   { return Task.m_currentThread.ParentProcess; }
        ulong ID()              { return m_id;       }
        ulong UID()             { return m_uid;      }
        ulong GID()             { return m_gid;      }
        bool IsKernel()         { return m_isKernel; }
        Paging PageTable()      { return m_paging;   }
        package auto Threads()  { return m_threads;  }
        auto WorkingDirectory() { return m_cwd;      }
    }
    
    package static Process Initialize() {
        if (Task.ThreadCount)
            return null;

        Process process    = new Process();
        process.m_paging   = VirtualMemory.KernelPaging;
        process.m_cwd      = VFS.Root;
        process.m_isKernel = true;

        /* Kernel thread */
        Thread t           = new Thread(process);
        with (t) {
            Name           = "Kernel";
            State          = ThreadState.Running;
            SetKernelStack();
        }
    
        return process;
    }

    private this() {
        CallTable[] callTable = [

        ];

        m_id        = Task.NextPID;
        m_threads   = new LinkedList!Thread();
        m_resources = new List!Resource();

        if (Thread.Current !is null) {
            m_uid       = Process.Current.m_uid;
            m_gid       = Process.Current.m_gid;
            m_isKernel  = Process.Current.m_isKernel;
            m_paging    = Process.Current.m_paging;
            m_cwd       = Process.Current.m_cwd;
        }

        Task.Processes.Add(this);
        super(DeviceType.Task, IDENTIFIER, 0x01, callTable);
    }

    this(void delegate() ProcessStart) {
        this();
        
        CopyResources();
        new Thread(this, ProcessStart);
    }

    this(void function() ProcessStart) {
        this();

        CopyResources();
        new Thread(this, ProcessStart);
    }

    this(string fileName, string[] arguments) {
        this();
        //TODO: load binary file and exec it
        //Dont copy resources
        //Copy paging from VirtualMemory.KernelPaging
    }

    ~this() {
        foreach (x; m_resources) {
            if (x.DetachProcess(this))
                delete x;
        }

        foreach (x; m_threads)
            delete x;

        delete m_paging;
        delete m_threads;
        delete m_resources;
    }

    void Start() {
        m_threads.First.Value.Start();
    }

    bool AttachResource(Resource resource) {
        if (m_resources.Contains(resource))
            return false;

        if (!resource.AttachProcess(this))
            return false;

        m_resources.Add(resource);
        return true;
    }

    bool DetachResource(Resource resource) {
        if (!m_resources.Remove(resource))
            return false;

        if (resource.DetachProcess(this))
            delete resource;

        return true;
    }

    package ulong[] AllocUserStack(ulong size = Thread.USER_STACK_SIZE) {
        for (ulong i = 0; i < size; i += Paging.PAGE_SIZE) {
            m_userStack -= Paging.PAGE_SIZE;
            m_paging.AllocFrame(m_userStack, AccessMode.DefaultUser); //TODO: Nejako nefunguje :/
        }

        return (cast(ulong *)m_userStack)[0 .. size];
    }

    private void CopyResources() {
        foreach (x; Current.m_resources) {
            if (x.AttachProcess(this))
                m_resources.Add(x);
        }
    }
}