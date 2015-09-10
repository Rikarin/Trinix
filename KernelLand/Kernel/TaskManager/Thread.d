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

module TaskManager.Thread;

import Core;
import Library;
import TaskManager;
import Architecture;
import ObjectManager;
import SyscallManager;
import MemoryManager;


enum ThreadState {
    Null,
    Active,
    Sleeping,
    MutexSleep,
    RWLockSleep,
    SemaphoreSleep,
    QueueSleep,
    EventSleep,
    Waiting,
    PreInit,
    Zombie,
    Dead,
    Buried
}

enum ThreadEvent : ulong {
    VFS       = 0x01,
    IPCMesage = 0x02,
    signal    = 0x04,
    Timer     = 0x08,
    ShortWait = 0x10,
    DeadChild = 0x20
}

struct IPCMessage {
    Thread Source;
    byte[] Data;
}


final class Thread {
    enum STACK_SIZE            = 0x4000;
    enum USER_STACK_SIZE       = 0x1000; //* 10
    enum MIN_PRIORITY          = 10;
    enum DEFAULT_PRIORITY      = 5;
    enum DEFAULT_QUANTUM       = 5;
    //private enum THREAD_RETURN = 0xDEADC0DE; //TODO: deprecated, thread will not return integer anymore!

    private ulong m_id;
    private string m_name;

    private ThreadState m_state;
    private SpinLock m_spinLock;

    private Process m_process;
    private Thread m_parent;

    //TODO: synchronized list??
    private LinkedList!Thread m_lastDeadChild;
    private Mutex m_deadChildLock;

    private ulong[] m_kernelStack;
    private ulong[2] m_syscallStack;
    private ulong[] m_userStack;
    private TaskState m_savedState;

    /* Tento shit sa pouziva vtedy ked na threadu vyskoci nejaky exception */
    private long m_curFaultNum;
    private void* m_faultHandler; //TODO: pouzit nejaku lepsiu sracku

    private SignalType m_pendingSignal;
    private LinkedList!(IPCMessage *) m_messages;

    private int m_quantum;
    private int m_remaining;
    //package int _curCPU;

    private ulong m_eventState;
    private void* m_waitPointer; //WTF??
    private ulong m_retStatus; /* For internal use only! */

    private int m_priority;
    private LinkedListNode!Thread m_node;

    //private int _errno; //WAT?


    package this(Process process) {
        m_id              = Task.NextTID;
        m_state           = ThreadState.PreInit;
        m_process         = process;
        m_name            = "Unnamed Thread";
        m_remaining       = DEFAULT_QUANTUM;
        m_quantum         = DEFAULT_QUANTUM;
        m_priority        = DEFAULT_PRIORITY;
                          
        m_spinLock        = new SpinLock();
        m_lastDeadChild   = new LinkedList!Thread();
        m_deadChildLock   = new Mutex();
        m_messages        = new LinkedList!(IPCMessage *)();
        m_node            = new LinkedListNode!Thread(this);
        m_kernelStack     = new ulong[STACK_SIZE];
        m_userStack       = new ulong[USER_STACK_SIZE];//TODO: ParentProcess.AllocUserStack();
        m_syscallStack[1] = cast(ulong)m_kernelStack.ptr + STACK_SIZE / 2;

        m_savedState.SSEInt.Create();
        m_savedState.SSESyscall.Create();
        m_process.Threads.Add(this);
    }

    this(void delegate() ThreadStart) {
        this(Task.CurrentProcess);
    }

    this(void function() ThreadStart) {
        this(Task.CurrentProcess);

        m_kernelStack[0] = cast(ulong)ThreadStart;
    }

    package this(Process process, void delegate() ThreadStart) {
        this(process);
    }

    package this(Process process, void function() ThreadStart) {
        this(process);

        m_kernelStack[0] = cast(ulong)ThreadStart;
    }

    ~this() {
        RemoveActive();
        m_state = ThreadState.Buried;
        m_process.Threads.Remove(this);

        if (!m_process.Threads.Count)
            delete m_process;

        delete m_name;
        delete m_node;
        delete m_spinLock;
        delete m_deadChildLock;
        delete m_messages;
        delete m_kernelStack;
        delete m_savedState.SSEInt.Data;
        delete m_savedState.SSESyscall.Data;
    }

    package void SetKernelStack() {
        CPU.TSSTable.RSP0 = cast(v_addr)m_kernelStack.ptr + STACK_SIZE;

        Port.SwapGS();
        Port.WriteMSR(SyscallHandler.Registers.IA32_GS_BASE, cast(ulong)m_syscallStack.ptr);
        Port.SwapGS();
    }

    @property {
        ulong ID()                 { return m_id;           }
        string Name()              { return m_name;         }
        ref auto Node()            { return m_node;         }
        int Priority()             { return m_priority;     }
        ref int Quantum()          { return m_quantum;      }
        void* WaitPointer()        { return m_waitPointer;  }
        ref int Remaining()        { return m_remaining;    }
        ref ulong RetStatus()      { return m_retStatus;    }
        long CurrentFaultNum()     { return m_curFaultNum;  }
        Process ParentProcess()    { return m_process;      }
        ref ThreadState State()    { return m_state;        }
        ref void* FaultHandler()   { return m_faultHandler; }
        ref TaskState SavedState() { return m_savedState;   }
        
        void Name(string value) {
            delete m_name;
            m_name = value;
        }
        
        void Priority(int priority) {
            if (priority < 0)
                priority = 0;

            if (priority > MIN_PRIORITY)
                priority = MIN_PRIORITY;
            
            m_priority = priority;
        }
    }

    void Start() {
        m_savedState.RSP = cast(void *)m_kernelStack.ptr + STACK_SIZE;
        m_savedState.RIP = cast(void *)&NewThread;
        AddActive();

        Log("Thread Start %x", cast(ulong)m_savedState.RSP);
    }

    private static void NewThread() {
        with (Task.CurrentThread) {
            Port.Cli();
            DeviceManager.EOI(0);

            if (Task.CurrentThread.ParentProcess.IsKernel)
                Run(0x202, m_kernelStack[0], 0x08, 0x10);
            else
                Run(0x202, m_kernelStack[0], 0x1B, 0x23);
        }
    }

    private void Run(ulong flags, ulong ip, ushort cs, ushort ss) {
        ulong* st = cast(ulong *)(cast(ulong)m_userStack.ptr + USER_STACK_SIZE);
        *st-- = ss;
        *st-- = cast(ulong)m_userStack.ptr + USER_STACK_SIZE;
        *st-- = flags;
        *st-- = cs;
        *st-- = ip;
    
        *st-- = ss;
        *st-- = ss;
        *st-- = ss;
        *st   = ss;

        asm {
            mov RSP, st;
            mov DS, [RSP];
            add RSP, 8;
            mov ES, [RSP];
            add RSP, 8;
            popq FS;
            popq GS;

            iretq;
        }
    }

/*  ulong WaitTID(ulong tid, ref ThreadState status) {
        if (tid == -1) {
            ulong events = WaitEvents(ThreadEvent.DeadChild);
            if (events & ThreadEvent.DeadChild) {
                assert(_lastDeadChild.Count);
                Thread deadThread = _lastDeadChild.First.Value;
                _lastDeadChild.RemoveFirst();

                if (_lastDeadChild.Count)
                    PostEvent(ThreadEvent.DeadChild);
                else
                    ClearEvent(ThreadEvent.DeadChild);
                _deadChildLock.Release();

                assert(deadThread._status == ThreadState.Zombie);
                deadThread._status = ThreadState.Dead;

                ulong ret = deadThread._id;
                status = deadThread._status;
                delete deadThread;
                return ret;
            } else
                Log("Threads: TODO: WaitTID(tid = -1) - Any Child");
        } else if (tid == 0)
            Log("Threads: TODO: WaitTID(tid = 0) - Any Child/Sibling");
        else if (tid < -1)
            Log("Threads: TODO: WaitTID(tid < -1) - TGID");
        else if (tid > 0) {
            ulong id;
            do
                id = WaitTID(-1, status);
            while (id != tid || id != -1);

            return id;
        }

        return -1;
    }
*/
    void Exit(ulong status) {
        Kill(status && 0xFF);

        while(true)
            Port.Halt();
    }

    void Kill(ulong status) {
        bool isCurrentThread = this == Task.CurrentThread;

        m_spinLock.WaitOne();
        scope(exit) m_spinLock.Release();

        foreach (x; m_messages) {
            auto a = x.Value;
            delete a;
        }

        Task.ThreadLock.WaitOne();
        switch (m_state) {
            case ThreadState.PreInit:
                break;

            case ThreadState.Sleeping:
                break;

            case ThreadState.Active:
                if (!isCurrentThread)
                    Task.Threads.Remove(m_node);

                m_remaining = 0;
                m_quantum = 0;
                break;

            case ThreadState.Zombie:
                Task.ThreadLock.Release();
                return;

            default:
                Log("Threads: Kill - unsupported thread status");
        }

        m_retStatus = status;
        m_state     = ThreadState.Zombie;
        Task.ThreadLock.Release();

        m_parent.m_deadChildLock.WaitOne();
        m_parent.m_lastDeadChild.Add(this);
        m_parent.PostEvent(ThreadEvent.DeadChild);

        if (isCurrentThread)
            while (true)
                Yield();
    }

    void Yield() {
        Task.Scheduler();
    }

    void WaitForStatusEnd(ThreadState status) {
        assert(status != ThreadState.Active);
        assert(status != ThreadState.Dead);

        while (m_state == status)
            Yield();
    }

    ulong Sleep(ThreadState status, void* ptr, ulong num, SpinLock lock) {
        RemoveActive();
        m_state       = status;
        m_waitPointer = ptr;
        m_retStatus   = num;

        if (lock)
            lock.Release();

        WaitForStatusEnd(status);
        m_waitPointer = null;
        return m_retStatus;
    }

    void Sleep() {
        if (m_messages.Count)
            return;

        RemoveActive();
        m_state = ThreadState.Sleeping;
        WaitForStatusEnd(ThreadState.Sleeping);
    }

    bool Wake() {
        switch (m_state) {
            case ThreadState.Active:
                return false;

            case ThreadState.Sleeping:
                AddActive();
                return true;

            case ThreadState.SemaphoreSleep:
                Semaphore semaphore = cast(Semaphore)m_waitPointer;
                semaphore.LockInternal();
                scope(exit) semaphore.UnlockInternal();

                if (!semaphore.Waiting.Remove(this) && !semaphore.Signaling.Remove(this))
                    return false;
                    
                m_retStatus = 0;
                AddActive();
                return true;

            case ThreadState.Waiting:
                return false;

            case ThreadState.Dead:
                return false;

            default:
                return false;
        }
    }

    void RemoveActive() {
        Task.ThreadLock.WaitOne();
        Task.Threads.Remove(m_node);
        Task.ThreadLock.Release();
    }

    void AddActive() {
        if (m_state == ThreadState.Active || !m_savedState.RIP)
            return;
        m_state = ThreadState.Active;

        Task.ThreadLock.WaitOne();
        if (Task.CurrentThread != this)
            Task.Threads.AddLast(m_node);
        Task.ThreadLock.Release();
    }

    void Fault(long number) {
        if (m_faultHandler is null) {    /* Panic */
            //TODO: fix me pls Kill(-1);

            Port.Sti();
            Port.Halt();
            return;
        }

        if (m_curFaultNum) {             /* Double fault */
            Log("Threads: Fault: Double fault...");
            //Kill(-1);

            Port.Sti();
            Port.Halt();
            return;
        }

        m_curFaultNum = number;
        Task.CallFaultHandler(this);
    }

    void SegFault(void* address) {
        Log("Threads: Fault: segment fault...");
        Fault(1);
    }




    /* Signals */
    void PostSignal(SignalType signal) {
        m_pendingSignal = signal;
        PostEvent(ThreadEvent.signal);
    }
    //TODO




    /* Events */
    void PostEvent(ulong eventMask) {
        m_spinLock.WaitOne();
        scope(exit) m_spinLock.Release();

        m_eventState |= eventMask;

        switch (m_state) {
            case ThreadState.EventSleep:
                if (m_retStatus & eventMask)
                    AddActive();
                break;

            case ThreadState.SemaphoreSleep:
                if (eventMask & ThreadEvent.Timer)
                        Semaphore.ForceWake(this);
                break;

            default:
        }
    }

    void ClearEvent(ulong eventMask) {
        m_eventState &= ~eventMask;
    }

    ulong WaitEvents(ulong eventMask) {
        if (!eventMask)
            return 0;

        m_spinLock.WaitOne();
        scope(exit) m_spinLock.Release();

        if ((m_eventState & eventMask) == 0) {
            Sleep(ThreadState.EventSleep, null, eventMask, m_spinLock);
            m_spinLock.WaitOne();
        }

        ulong ret = m_eventState & eventMask;
        m_eventState &= ~eventMask;

        return ret;
    }

    /* Messages */
    bool SendMessage(byte[] data) {
        m_spinLock.WaitOne();
        scope(exit) m_spinLock.Release();

        if (m_state == ThreadState.Dead)
            return false;

        IPCMessage* msg = new IPCMessage();
        msg.Source      = Task.CurrentThread;
        msg.Data[]      = data;
        m_messages.Add(msg);

        PostEvent(ThreadEvent.IPCMesage);
        return true;
    }

    bool GetMessage(ref Thread source, ref byte[] data) {
        if (!m_messages.Count)
            return false;

        m_spinLock.WaitOne();
        scope(exit) m_spinLock.Release();

        with (m_messages.First.Value) {
            source = Source;
            data[] = Data;

            delete Data;
        }
        m_messages.RemoveFirst();

        if (m_messages.Count)
            m_eventState |= ThreadEvent.IPCMesage;

        return true;
    }
}