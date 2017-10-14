/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Library.SpinLock;


class SpinLock {
    private long m_locked;

    private long AtomicExchange(long* value) {
        asm {
            naked;
            mov RAX, 1;
            xchg [RSI], RAX;
            ret;
        }
    }

    this() {
        m_locked = false;
    }

    this(bool initiallyOwned) {
        m_locked = initiallyOwned;
    }

    bool WaitOne() {
        while (AtomicExchange(&m_locked)) {}
        return true;
    }

    void Release() {
        m_locked = false;
    }

    @property bool IsLocked() {
        return m_locked != 0;
    }
}