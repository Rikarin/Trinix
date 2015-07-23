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
 * 
 * TODO:
 *      o Signal handler
 */

module TaskManager.Process;

import Library;
import VFSManager;
import TaskManager;
import Architecture;
import MemoryManager;
import SyscallManager;


final class Process {
    private v_addr m_userStack = 0xFFFFFFFF_80000000;

    private ulong m_id;
    private ulong m_uid;
    private ulong m_gid;
    private bool m_isKernel;

    private Process m_parent;
    package Paging m_paging;
    private LinkedList!Thread m_threads;
    private DirectoryNode m_cwd;

    private List!Resource m_resources;

    @property {
        ulong ID()             { return m_id;       }
        ulong UID()            { return m_uid;      }
        ulong GID()            { return m_gid;      }
        Paging PageTable()     { return m_paging;   }
        bool IsKernel()        { return m_isKernel; }
        package auto Threads() { return m_threads;  }
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
        t.Name             = "Kernel";
        t.Status           = ThreadStatus.Active;
        t.SetKernelStack();

        /* Idle task */
        Task.IdleTask      = new Thread(t);
        with (Task.IdleTask) {
            Name           = "Idle Task";
            Priority       = MIN_PRIORITY;
            Quantum        = 1;
            Start(&Task.Idle, null);
        }
    
        return process;
    }

    private this() {
        m_id        = Task.NextPID;
        m_threads   = new LinkedList!Thread();
        m_resources = new List!Resource();

        Task.Processes.Add(this);
    }

    /* Clone other._process to this process and ot to this process */
    this(Thread other) {
        this();
        m_uid      = other.ParentProcess.m_uid;
        m_gid      = other.ParentProcess.m_gid;
        m_isKernel = other.ParentProcess.m_isKernel;
        m_parent   = other.ParentProcess;
        m_paging   = new Paging(other.ParentProcess.m_paging);
        m_cwd      = other.ParentProcess.m_cwd;

        foreach (x; other.ParentProcess.m_resources) {
            if (x.AttachProcess(this))
                m_resources.Add(x);
        }

        new Thread(this, other);
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

    package ulong[] AllocUserStack(ulong size = Thread.USER_STACK_SIZE) {
        for (ulong i = 0; i < size; i += Paging.PAGE_SIZE) {
            m_userStack -= Paging.PAGE_SIZE;
            m_paging.AllocFrame(m_userStack, AccessMode.DefaultUser); //TODO: Nejako nefunguje :/
        }

        return (cast(ulong *)m_userStack)[0 .. size];
    }
}