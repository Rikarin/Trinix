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

module TaskManager.Semaphore;

import Library;
import TaskManager;


class Semaphore {
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
        m_value     = initialCount;
        m_maxValue  = maxCount;
        m_name      = name;
        m_spinLock  = new SpinLock();
        m_waiting   = new LinkedList!Thread();
        m_signaling = new LinkedList!Thread();
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

    int WaitOne() {
        int taken;
        m_spinLock.WaitOne();

        if (m_value > 0) {
            taken = 1;
            m_value--;
        } else {
            m_waiting.Add(Task.CurrentThread);
            taken = cast(int)Task.CurrentThread.Sleep(ThreadState.SemaphoreSleep, cast(void *)this, 1, m_spinLock);
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
            return taken;
        }

        return -1;
    }

    int Release(int releaseCount) in {
        assert(releaseCount >= 0);
    } body {
        m_spinLock.WaitOne();
        int added;

        if (m_maxValue && m_value == m_maxValue) {
            m_signaling.Add(Task.CurrentThread);
            added = cast(int)Task.CurrentThread.Sleep(ThreadState.SemaphoreSleep, cast(void *)this, releaseCount, m_spinLock);
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

    package static void ForceWake(Thread thread) {
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
    }
}