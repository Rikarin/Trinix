﻿/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module TaskManager.Thread;

import Core;
import Library;
import Diagnostics;
import TaskManager;
import Architecture;
import ObjectManager;
import MemoryManager;


enum ThreadState {
    Dead,
    Ready,         /// < Thread is ready to get sheduled
    Running,       /// < Thread is already running on Core
    Stopped,       /// < Stopped
    Join,          /// < Wait to join another thread
    MutexWait,     /// < Wait for mutex
    SemaphoreWait, /// < Wait for semaphore
    ThreadWait,
    InterruptWait, /// < Wait for interrupt
    EventWait,
    Sleep,
    ReceiveWait,
    SendWait,
    ReplyWait
}

/*enum ThreadEvent : ulong { //TODO: delete
    VFS       = 0x01,
    IPCMesage = 0x02,
    signal    = 0x04,
    Timer     = 0x08,
    ShortWait = 0x10,
    DeadChild = 0x20
}*/

struct Message {
    Thread Source;
    byte[] Data;
    bool IsPulse;

    ~this() {
        if (Data !is null)
            delete Data;
    }
}


final class Thread : Resource {
    private enum IDENTIFIER = "com.trinix.TaskManager.Thread";

    enum THREAD_RETURN    = 0xDEADC0DE;
    enum STACK_SIZE       = 0x32000;
    enum USER_STACK_SIZE  = 0x32000;
    enum MIN_PRIORITY     = 10;
    enum DEFAULT_PRIORITY = 5;
    enum DEFAULT_QUANTUM  = 5;

    private ulong m_id;
    private ThreadState m_state;
    private SpinLock m_spinLock;

    private Process m_process;
    private Thread m_parent;

    //TODO: synchronized list??
    private LinkedList!Thread m_lastDeadChild;
    private Mutex m_deadChildLock;

    /* Stacks */
    private ulong[] m_kernelStack;
    private ulong[2] m_syscallStack;
    private ulong[] m_userStack;
    private TaskState m_savedState;

    /* Exception handler */
    private long m_curFaultNum;
    private void* m_faultHandler;

    /* CPU quantum */
    private int m_quantum;
    private int m_remaining;
    //package int _curCPU;

    /* IPC */
    //private SignalType m_pendingSignal;
    private LinkedList!(Message *) m_messages;

    private ulong m_eventState;
    private void* m_waitPointer; //WTF??
    private ulong m_retStatus; /* For internal use only! */

    private int m_priority;
    private LinkedListNode!Thread m_node;

    //private int _errno; //WAT?

    package this(Process process) {
        CallTable[] callTable = [

        ];

        m_id              = Task.NextTID;
        m_state           = ThreadState.Stopped;
        m_process         = process;
        m_remaining       = DEFAULT_QUANTUM;
        m_quantum         = DEFAULT_QUANTUM;
        m_priority        = DEFAULT_PRIORITY;
                          
        m_spinLock        = new SpinLock();
        m_lastDeadChild   = new LinkedList!Thread();
        m_deadChildLock   = new Mutex();
        m_messages        = new LinkedList!(Message *)();
        m_node            = new LinkedListNode!Thread(this);
        m_kernelStack     = new ulong[STACK_SIZE / 8];
        m_userStack       = new ulong[USER_STACK_SIZE / 8];//TODO: ParentProcess.AllocUserStack();
        m_syscallStack[1] = cast(ulong)m_kernelStack.ptr + STACK_SIZE / 2;

        m_savedState.SSEInt.Create();
        m_savedState.SSESyscall.Create();
        m_process.Threads.Add(this);

        super(DeviceType.Task, IDENTIFIER, 0x01, callTable);
    }

    this(void delegate() ThreadStart) {
        this(Process.Current);

        m_parent = Current;
    }

    this(void function() ThreadStart) {
        this(Process.Current);

        m_parent         = Current;
        m_kernelStack[0] = cast(ulong)ThreadStart;
    }

    package this(Process process, void delegate() ThreadStart) {
        this(process);

        //TODO
    }

    package this(Process process, void function() ThreadStart) {
        this(process);

        m_kernelStack[0] = cast(ulong)ThreadStart;
    }

    ~this() {
        RemoveActive(ThreadState.Dead);
        m_process.Threads.Remove(this);

        if (!m_process.Threads.Count)
            delete m_process;

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
        static auto Current()            { return Task.m_currentThread; }
        ulong ID()                       { return m_id;                 }
        int Priority()                   { return m_priority;           }
        ref auto Node()                  { return m_node;               }
        ref int Quantum()                { return m_quantum;            }
        void* WaitPointer()              { return m_waitPointer;        }
        ref int Remaining()              { return m_remaining;          }
        ref ulong RetStatus()            { return m_retStatus;          }
        long CurrentFaultNum()           { return m_curFaultNum;        }
        Process ParentProcess()          { return m_process;            }
        ref ThreadState State()          { return m_state;              }
        ref void* FaultHandler()         { return m_faultHandler;       }
        ref TaskState SavedState()       { return m_savedState;         }
        override bool Name(string value) { return super.Name(value);    }
        
        override string Name() {
            if (super.Name is null)
                return "Unnamed Thread";

            return super.Name;
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

        Debugger.Log(LogLevel.Debug, "Thread", "Start at %x", cast(ulong)m_savedState.RSP);
    }

    private static void NewThread() {
        with (Current) {
            Port.Cli();
            DeviceManager.EOI(0);

            if (ParentProcess.IsKernel)
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

    /* WTF is this??? ... Join.. */
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

    void Kill(ulong status) { //TODO
        bool isCurrentThread = this == Current;

        m_spinLock.WaitOne();
        scope(exit) m_spinLock.Release();

        foreach (x; m_messages) {
            auto a = x.Value;
            delete a;
        }

        Task.ThreadLock.WaitOne();
        switch (m_state) {
            case ThreadState.Dead:
            case ThreadState.Stopped:
                break;

            /*case ThreadState.Active:
                if (!isCurrentThread)
                    Task.Threads.Remove(m_node);

                m_remaining = 0;
                m_quantum   = 0;
                break;

            case ThreadState.Zombie:
                Task.ThreadLock.Release();
                return;*/

            default:
                Debugger.Log(LogLevel.Emergency, "Thread", "Threads: Kill - unsupported thread state %d", cast(long)m_state);
        }

        m_retStatus = status;
        m_state     = ThreadState.Dead;
        Task.ThreadLock.Release();

        m_parent.m_deadChildLock.WaitOne();
        m_parent.m_lastDeadChild.Add(this);
        m_parent.m_deadChildLock.Release();

        /* Its suicide */
        if (isCurrentThread)
            while (true)
                Task.Yield();
    }

    void SetAndWaitForStatusEnd(ThreadState state) {
        assert(state != ThreadState.Ready);
        assert(state != ThreadState.Running);
        assert(state != ThreadState.Dead);

        RemoveActive(state);
        WaitForStatusEnd(state);
    }

    void WaitForStatusEnd(ThreadState state) {
        assert(state != ThreadState.Ready);
        assert(state != ThreadState.Running);
        assert(state != ThreadState.Dead);

        while (m_state == state)
            Task.Yield();
    }

    /*ulong Sleep(ThreadState status, void* ptr, ulong num, SpinLock lock) {
        RemoveActive();
        m_state       = status;
        m_waitPointer = ptr;
        m_retStatus   = num;

        if (lock)
            lock.Release();

        WaitForStatusEnd(status);
        m_waitPointer = null;
        return m_retStatus;
    }*/

    void Sleep() {
        if (m_messages.Count)
            return;

        SetAndWaitForStatusEnd(ThreadState.Sleep);
    }

    /*enum ThreadState {
    Join,          /// < Wait to join another thread
    MutexWait,     /// < Wait for mutex
    SemaphoreWait, /// < Wait for semaphore
    ThreadWait,
    InterruptWait, /// < Wait for interrupt
    EventWait,
    ReceiveWait,
    SendWait,
    ReplyWait
}*/
    bool Wake() {
        switch (m_state) {
            case ThreadState.Dead:
            case ThreadState.Ready:
            case ThreadState.Running:
                return false;

            case ThreadState.Stopped:
            case ThreadState.Sleep:
                AddActive();
                return true;

            case ThreadState.ReceiveWait:
                AddActive(m_remaining ? true : false);
                return true;


           /* case ThreadState.SemaphoreSleep:
                Semaphore semaphore = cast(Semaphore)m_waitPointer;
                semaphore.LockInternal();
                scope(exit) semaphore.UnlockInternal();

                if (!semaphore.Waiting.Remove(this) && !semaphore.Signaling.Remove(this))
                    return false;
                    
                m_retStatus = 0;
                AddActive();
                return true;*/

            default:
                return false;
        }
    }

    void RemoveActive(ThreadState state) {
        m_state = state;

        Task.ThreadLock.WaitOne();
        Task.Threads.Remove(m_node);
        Task.ThreadLock.Release();
    }

    void AddActive(bool addAsFirst = false) {
        if (m_state == ThreadState.Running ||
            m_state == ThreadState.Ready   ||
            m_state == ThreadState.Dead    ||
            !m_savedState.RIP)
            return;

        m_state = ThreadState.Ready;
        Task.ThreadLock.WaitOne();
        if (Current != this) {
            if (addAsFirst)
                Task.Threads.AddFirst(m_node);
            else
                Task.Threads.AddLast(m_node);
        }
        Task.ThreadLock.Release();
    }

    void Fault(long number) {
        if (m_faultHandler is null) {    /* Panic */
            Debugger.Log(LogLevel.Debug, "Thread", "Panic was thrown in thread #%d", m_id);
            Kill(-1);
        }

        if (m_curFaultNum) {             /* Double fault */
            Debugger.Log(LogLevel.Debug, "Thread", "Double fault was thrown in thread #%d", m_id);
            Kill(-1);
        }

        m_curFaultNum = number;
        Task.CallFaultHandler(this);
    }

    void SegFault(void* address) {
        Debugger.Log(LogLevel.Debug, "Thread", "Segment fault was thrown in thread #%d at address: %x", m_id, cast(ulong)address);
        //TODO: dump memory MM_DumpTables
        Fault(1);
    }

    /* Signals */
   /* void PostSignal(SignalType signal) {
        m_pendingSignal = signal;
        PostEvent(ThreadEvent.signal);
    }*/
    //TODO

    /* Events */
   /* void PostEvent(ulong eventMask) {
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
    }*/

    /* Messages */
    void SendMessage(byte[] data) {
        m_spinLock.WaitOne();
        scope(exit) m_spinLock.Release();

        if (m_state == ThreadState.Dead)
            return;

        Message* msg = new Message();
        msg.Source   = Current;
        msg.Data[]   = data;
        m_messages.Add(msg);

        if (m_state == ThreadState.ReceiveWait) {
            m_remaining         = Current.m_remaining;
            Current.m_remaining = 0;
            Wake();
        }
            
        Current.m_state = ThreadState.SendWait;
        WaitForStatusEnd(ThreadState.SendWait);
        WaitForStatusEnd(ThreadState.ReplyWait);
    }

    void PulseMessage(byte[] data) {
        //TODO:
        assert(false);
    }

    void ReceiveMessage(ref Thread source, ref byte[] data) {
        if (!m_messages.Count) {
            m_state = ThreadState.ReceiveWait;
            WaitForStatusEnd(ThreadState.ReceiveWait);
        }

        m_spinLock.WaitOne();
        scope(exit) m_spinLock.Release();

        with (m_messages.First) {
            source = Value.Source;
            data[] = Value.Data;

            delete Value;
        }
        m_messages.RemoveFirst();
        source.m_state = ThreadState.ReplyWait;
    }
}