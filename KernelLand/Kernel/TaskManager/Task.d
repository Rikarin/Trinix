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
 *      o Syscalls: create (mutex, spinlock, rwlock, semaphore, process, thread, shared memory)
 */

module TaskManager.Task;

import Core; //TODO: logs...
import Library;
import Diagnostics;
import TaskManager;
import Architecture;
import ObjectManager;

extern(C) private void* _Proc_Read_RIP();


struct SSEState {
    byte[] Data;

    void Create() {
        Data = new byte[0x20F];
    }

    void Save() {
        Port.SaveSSE(((cast(ulong)Data.ptr) + 0x0F) & ~0x0F);
    }

    void Load() {
        Port.RestoreSSE(((cast(ulong)Data.ptr) + 0x0F) & ~0x0F);
    }
}

struct TaskState {
    void* RIP, RSP, RBP;
    SSEState SSEInt;
    SSEState SSESyscall;
}


abstract final class Task {
    private enum IDENTIFIER = "com.trinix.TaskManager";

    private __gshared ulong m_nextPID = 1;
    private __gshared ulong m_nextTID = 1;

    private __gshared SpinLock m_spinLock;
    private __gshared LinkedList!Process m_procs;
    private __gshared LinkedList!Thread m_threads;
    package __gshared Thread m_currentThread;


    @property {
        package static SpinLock ThreadLock() { return m_spinLock;      }
        package static ulong NextPID()       { return m_nextPID++;     } //TODO: spinlock
        package static ulong NextTID()       { return m_nextTID++;     } //TODO: spinlock
        package static auto Threads()        { return m_threads;       }
        package static auto Processes()      { return m_procs;         }
        package static size_t ThreadCount()  { return m_threads.Count; }
    }

    static void Initialize() {
        m_spinLock = new SpinLock();
        m_procs    = new LinkedList!Process();
        m_threads  = new LinkedList!Thread();

        Process proc    = Process.Initialize();
        m_currentThread = proc.Threads.First.Value;

        /* Idle task */
        Thread idle  = new Thread(&Task.Idle);
        with (idle) {
            Name     = "Idle Task";
            Priority = MIN_PRIORITY;
            Quantum  = 1;
            Start();
        }

        ResourceManager.AddCallTable(IDENTIFIER, &StaticCallback);
    }

    static void Finalize() {
        delete m_threads;
        delete m_procs;
        delete m_spinLock;
    }

    static void Scheduler() {
        if (m_spinLock.IsLocked)
            return;
    
        if (CurrentThread.Remaining--)
            return;

        void* rsp, rbp;
        asm {
            mov rsp, RSP;
            mov rbp, RBP;
        }

        void* rip = _Proc_Read_RIP();
        if (cast(ulong)rip == 0x12341234UL)
            return;

        CurrentThread.SavedState.RIP = rip;
        CurrentThread.SavedState.RSP = rsp;
        CurrentThread.SavedState.RBP = rbp;

        Reschedule();
    }

    private static void Reschedule() {
        Thread next = GetNextToRun();
        //Log("Rescheduling: %d, priority: %d, name: %s, total: %d", next.ID, next.Priority, next.Name, ThreadCount);
        if (next is null || next == CurrentThread)
            return;

        /* Switch to the next thread */
        m_currentThread = next;
        m_currentThread.SetKernelStack();
        m_currentThread.ParentProcess.m_paging.Install();

        with (CurrentThread.SavedState)
            SwitchTasks(RSP, RBP, RIP);
    }

    private static Thread GetNextToRun() {
        m_spinLock.WaitOne();
        scope(exit) m_spinLock.Release();

        Thread next    = GetRunnable();
        next.Remaining = next.Quantum;

        if (next is CurrentThread)
            return CurrentThread;

        if (CurrentThread.State == ThreadState.Active)
            m_threads.AddLast(CurrentThread.Node);

        return next;
    }

    private static Thread GetRunnable() {
        for (int i = 0; i < Thread.MIN_PRIORITY; i++) {
            foreach (x; m_threads) {
                if (x.Value.Priority == i && x.Value.State == ThreadState.Active) {
                    auto ret = x.Value;
                    m_threads.Remove(x);
                    return ret;
                }
            }
        }

        return CurrentThread;
    }

    private static void SwitchTasks(void* rsp, void* rbp, void* rip) {      
        asm {
            naked;
            mov RBP, RSI;
            mov RSP, RDX;
            mov RAX, 0x12341234;
            jmp RDI;
        }
    }

    package static void CallFaultHandler(Thread thread) {
        Debugger.Log(LogLevel.Debug, "Task", "Thread fault %d in thread %d", thread.CurrentFaultNum, thread.ID);
        thread.Kill(-42); //TODO: call the handler saved in m_faultHandler
    }

    package static void Idle() {
        while (true)
            Port.Halt();
    }


    /**
    * Callback used by userspace apps for obtaining instance of speciffic
    * classes by calling this static syscall
    * 
    * Params:
    *      param1  =       TODO
    *      param2  =       TODO
    *      param3  =       TODO
    *      param4  =       TODO
    *      param5  =       TODO
    * 
    * Returns:
    *      SyscallReturn.Error     on failure
    */
    static long StaticCallback(long param1, long param2, long param3, long param4, long param5) {
        return SyscallReturn.Error;
    }
}