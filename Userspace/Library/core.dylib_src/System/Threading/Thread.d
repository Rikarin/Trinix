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

module System.Threading.Thread;

import System.Collections;

static import win32;


final class Thread {
    private static __gshared SafeDictionary!(uint, Thread) m_threads;

    private __gshared union {
        ThreadStart m_start;
        ParametrizedThreadStart m_parametrizedStart;
    }
    private Object m_arg;

    private {
        win32.HANDLE m_handle;
    }

    @property {
        static Thread CurrentThread() { return m_threads[win32.GetCurrentThreadId()]; }
    }

    static this() {
        m_threads = new SafeDictionary!(uint, Thread)();
        m_threads[win32.GetCurrentThreadId()] = new Thread();
    }

    private this() {

    }

    this(ThreadStart start) {
        m_start = start;
        Init();
    }

    this(ParametrizedThreadStart start) {
        m_parametrizedStart = start;
        Init();
    }

    ~this() {
        /*foreach (uint k, v; m_threads) {
            if (v == this) {
                m_threads.Remove(k);
                break;
            }
        }*/
    }

    void Start(Object arg = null) {
        m_arg = arg;
        win32.ResumeThread(m_handle);
    }









    private void Init() {
        uint id;
        m_handle      = win32.CreateThread(cast(win32.LPSECURITY_ATTRIBUTES)0, 0U, &ExecutableEntry, cast(void *)this, win32.CREATE_SUSPENDED, &id);
        m_threads[id] = this;
    }

    extern(Windows) {
        private static uint ExecutableEntry(void* thread) {
            Thread* t = cast(Thread *)thread;

            try {
                t.m_start();
            } catch (Throwable e) {
                throw e;
            }
            return 0;
        }
    }
}


alias void delegate() ThreadStart;
alias void delegate(Object x) ParametrizedThreadStart;