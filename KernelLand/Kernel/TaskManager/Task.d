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

module TaskManager.Task;

import Core; //TODO: logs...
import Library;
import TaskManager;
import Architecture;
import ObjectManager;

extern(C) private void* _Proc_Read_RIP();


struct SSEState {
    ulong Header;
    ulong Data;
}


struct TaskState {
    void* RIP, RSP, RBP;
    SSEState SSEInt;
    SSEState SSESyscall;
    bool IsSSEModified;
}


abstract final class Task {
    private __gshared ulong m_nextPID = 1;
    private __gshared ulong m_nextTID = 1;

    private __gshared SpinLock m_spinLock;
    private __gshared LinkedList!Process m_procs;
    private __gshared LinkedList!Thread[] m_threads;
    private __gshared Thread m_currentThread;
    private __gshared Thread m_idle;

    @property {
        static Thread CurrentThread()        { return m_currentThread;             }
        static Process CurrentProcess()      { return CurrentThread.ParentProcess; }
        package static SpinLock ThreadLock() { return m_spinLock;                  }
        package static ulong NextPID()       { return m_nextPID++;                 }
        package static ulong NextTID()       { return m_nextTID++;                 }
        package static ref Thread IdleTask() { return m_idle;                      }
        package static auto Threads()        { return m_threads;                   }
        package static auto Processes()      { return m_procs;                     }
        
        package static size_t ThreadCount() {
            size_t count;
            foreach (x; m_threads)
                if (x !is null)
                    count += x.Count;
            
            return count;
        }
    }

    static void Initialize() {
        m_spinLock = new SpinLock();
        m_procs    = new LinkedList!Process();
        m_threads  = new LinkedList!Thread[Thread.MIN_PRIORITY + 1];

        foreach (ref x; m_threads)
            x = new LinkedList!Thread();

        Process proc = Process.Initialize();
        m_currentThread = proc.Threads.First.Value;
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
        //Log.WriteLine("Debug: rescheduled: ", next.ID, " priority: ", next.Priority, " name: ", next.Name);

        if (next is null || next == CurrentThread)
            return;
            
        //CurrentThread.SavedState.IsSSEModified = false;
        //Port.DisableSSE();

        /// Change to next thread
        m_currentThread = next;
        m_currentThread.SetKernelStack();
        m_currentThread.ParentProcess.m_paging.Install();

        with (CurrentThread.SavedState)
            SwitchTasks(RSP, RBP, RIP);
    }

    private static Thread GetNextToRun() {
        ThreadLock.WaitOne();
        scope(exit) ThreadLock.Release();

        if (CurrentThread.Status == ThreadStatus.Active)
            Threads[CurrentThread.Priority].Add(CurrentThread);

        Thread next = GetRunnable();
        next.Remaining = next.Quantum;
        return next;
    }

    private static Thread GetRunnable() {
        foreach (x; m_threads) {
            if (x.Count) {
                foreach (y; x) {
                    if (y.Value.Status == ThreadStatus.Active) {
                        Thread ret = y.Value;
                        x.Remove(y);
                        return ret;
                    }
                }
            }
        }

        return m_idle;
    }

    private static void SwitchTasks(void* rsp, void* rbp, void* rip) {      
        asm {
            naked;
            mov RBP, RSI;
            mov RSP, RDI;
            mov RAX, 0x12341234;
            jmp RDX;
        }
    }

    package static void CallFaultHandler(Thread thread) {
        Log("Threads: Fault %d", thread.CurrentFaultNum);
        thread.Kill(-1);
        
        Port.Sti();
        Port.Halt();
        return;
    }

    package static void Idle() { //This is idle task
        while (true)
            Port.Halt();
    }
}