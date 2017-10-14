/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module TaskManager.Semaphore;

import Library;
import TaskManager;
import ObjectManager;


class Semaphore : Resource {
    private enum IDENTIFIER = "com.trinix.TaskManager.Semaphore";

    private string m_name;
    private int m_value;
    private int m_maxValue;
    private SpinLock m_spinLock;
    private LinkedList!Thread m_waiting;
    private LinkedList!Thread m_signaling;

    @property package LinkedList!Thread Waiting()   { return m_waiting;   }
    @property package LinkedList!Thread Signaling() { return m_signaling; }

    this(int initialCount, int maxCount, string name) in {
        assert(initialCount > 0);
        assert(maxCount > 0);
    } body {
        CallTable[] callTable = [

        ];

        m_value     = initialCount;
        m_maxValue  = maxCount;
        m_name      = name;
        m_spinLock  = new SpinLock();
        m_waiting   = new LinkedList!Thread();
        m_signaling = new LinkedList!Thread();

        super(DeviceType.IPC, IDENTIFIER, 0x01, callTable);
    }
    
    ~this() {
        delete m_signaling;
        delete m_spinLock;
        delete m_waiting;
        delete m_name;
    }

    package void LockInternal() {
        m_spinLock.WaitOne();
    }

    package void UnlockInternal() {
        m_spinLock.Release();
    }

    long WaitOne() {
        long taken;
        m_spinLock.WaitOne();

        if (m_value > 0) {
            taken = 1;
            m_value--;
        } else {
            m_waiting.Add(Thread.Current);
            m_spinLock.Release();
            Thread.Current.SetAndWaitForStatusEnd(ThreadState.SemaphoreWait);
            m_spinLock.WaitOne();
        }

        while ((!m_maxValue || m_value < m_maxValue) && m_signaling.Count) {
            Thread t    = m_signaling.First.Value;
            ulong given = (t.RetStatus && m_value + t.RetStatus < m_maxValue) ? t.RetStatus : m_maxValue - m_value;

            m_value    -= given;
            t.RetStatus = given;
            t.AddActive();

            m_signaling.RemoveFirst();
            m_spinLock.Release();
            //return taken;
        }

        return -1;
    }

    long Release(int releaseCount) in {
        assert(releaseCount >= 0);
    } body {
        m_spinLock.WaitOne();
        long added;

        if (m_maxValue && m_value == m_maxValue) {
            m_signaling.Add(Thread.Current);
           // added = Thread.Current.Sleep(ThreadState.SemaphoreSleep, cast(void *)this, releaseCount, m_spinLock);
            m_spinLock.WaitOne();
        } else {
            added    = (m_maxValue && m_value + releaseCount > m_maxValue) ? m_maxValue - m_value : releaseCount;
            m_value += releaseCount;
        }

        while (m_value && m_waiting.Count) {
            Thread t  = m_waiting.First.Value;
            int given = (t.RetStatus && m_value > t.RetStatus) ? cast(int)t.RetStatus : m_value;

            m_value    -= given;
            t.RetStatus = given;
            t.AddActive();

            m_spinLock.Release();
            m_waiting.RemoveFirst();
        }

        return added;
    }

   /* package static void ForceWake(Thread thread) {
        if (thread.State != ThreadState.SemaphoreSleep)
            return;

        Semaphore semaphore = cast(Semaphore)thread.WaitPointer;
        with (semaphore) {
            m_spinLock.WaitOne();
            m_waiting.Remove(thread);
            m_spinLock.Release();

            thread.RetStatus = 0;
            thread.AddActive();
        }
    }*/
}