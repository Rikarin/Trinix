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

module TaskManager.Mutex;

import Library;
import TaskManager;


class Mutex {
    private SpinLock m_spinLock;
    private LinkedList!Thread m_waiting;
    private Thread m_owner;

    this() {
        m_spinLock = new SpinLock();
        m_waiting  = new LinkedList!Thread();
    }

    ~this() {
        delete m_spinLock;
        delete m_waiting;
    }

    bool WaitOne() {
        m_spinLock.WaitOne();

        if (m_owner) {
            m_waiting.Add(Task.CurrentThread);
            Task.CurrentThread.Sleep(ThreadStatus.MutexSleep, cast(void *)this, 0, m_spinLock);
        } else {
            m_owner = Task.CurrentThread;
            m_spinLock.Release();
        }

        return true;
    }

    void Release() {
        m_spinLock.WaitOne();

        if (m_waiting.Count) {
            m_owner = m_waiting.First.Value;
            m_waiting.RemoveFirst();

            if (m_owner.Status != ThreadStatus.Active)
                m_owner.AddActive();
        } else
            m_owner = null;

        m_spinLock.Release();
    }

    bool IsLocked() {
        return m_owner !is null;
    }
}