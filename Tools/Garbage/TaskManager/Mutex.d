/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module TaskManager.Mutex;

import Library;
import TaskManager;
import ObjectManager;


class Mutex : Resource {
    private enum IDENTIFIER = "com.trinix.TaskManager.Mutex";

    private SpinLock m_spinLock;
    private LinkedList!Thread m_waiting;
    private Thread m_owner;

    this() {
        CallTable[] callTable = [

        ];

        m_spinLock = new SpinLock();
        m_waiting  = new LinkedList!Thread();

        super(DeviceType.IPC, IDENTIFIER, 0x01, callTable);
    }

    ~this() {
        delete m_spinLock;
        delete m_waiting;
    }

    bool WaitOne() {
        m_spinLock.WaitOne();

        if (m_owner) {
            m_waiting.Add(Thread.Current);

            m_spinLock.Release();
            Thread.Current.SetAndWaitForStatusEnd(ThreadState.MutexWait);
        } else {
            m_owner = Thread.Current;
            m_spinLock.Release();
        }

        return true;
    }

    void Release() {
        m_spinLock.WaitOne();

        if (m_waiting.Count) {
            m_owner = m_waiting.First.Value;
            m_waiting.RemoveFirst();

            if (m_owner.State == ThreadState.MutexWait)
                m_owner.AddActive();
        } else
            m_owner = null;

        m_spinLock.Release();
    }

    bool IsLocked() {
        return m_owner !is null;
    }
}