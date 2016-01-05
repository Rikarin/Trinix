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

module System.Collections.Queue;

import System;
import System.Collections;


class Queue(T) : IEnumerable!T {
    private T[] m_array;
    private long m_head;
    private long m_tail;
    private long m_count;

    @property {
        long Count() const { return m_count; }
    }

    int opApply(ForeachDelegate dg) {
        return opApply((ulong, ref T x) => dg(x));
    }

    int opApply(LongForeachDelegate dg) {
        long index = m_head;
        int result;
        long count;
        
        while (count < m_count) {
            result = dg(count++, m_array[index]);
            if (result)
                break;
                
            index = (index + 1) % m_array.length;
        }

        return result;
    }

    int opApplyReverse(ForeachDelegate dg) {
        return opApplyReverse((ulong, ref T x) => dg(x));
    }

    int opApplyReverse(LongForeachDelegate dg) {
        long index = m_head;
        long count = m_count;
        int result;
        
        while (count) {
            result = dg(count--, m_array[index]);
            if (result)
                break;
            
            index = (index - 1) % m_array.length;
        }
        
        return result;
    }

    this(long capacity = 4) in {
        assert(capacity > 0);
    } body {
        m_array = new T[capacity];
    }

    ~this() {
        //TODO: delete m_array;
    }

    void Clear() {
        m_array[] = null;
        m_head    = 0;
        m_tail    = 0;
        m_count   = 0;
    }

    void Enqueue(T item) {
        if (m_count == m_array.length)
            SetCapacity(m_array.length * 2);

        m_array[m_tail] = item;
        m_tail = (m_tail + 1) % m_array.length;
        m_count++;
    }

    T Dequeue() {
        if (!m_count)
            throw new InvalidOperationException();

        T ret  = m_array[m_head];
        m_head = (m_head + 1) % m_array.length;
        m_count--;

        return ret;
    }

    T Peek() {
        if (!m_count)
            throw new InvalidOperationException();

        return m_array[m_head];
    }

    bool Contains(T item) {
        long index = m_head;
        long count = m_count;

        while (count--) {
            if (item == m_array[index])
                return true;

            index = (index + 1) % m_array.length;
        }

        return false;
    }

    void CopyTo(T[] array, int index) {
        if (m_count) {
            auto min = Math.Min(index + array.length, m_count);

            if (m_head < m_tail) {
                array[0 .. min - index] = m_array[m_head .. m_head + min];
            } else {
                array[0 .. min - index - m_head] = m_array[m_head .. min];
                array[min - m_head - index .. min - index - m_head + m_tail] = m_array[0 .. m_tail];
            }
        }
    }

    T[] ToArray() {
        T[] ret = new T[m_count];

        if (m_count) {
            if (m_head < m_tail) {
                ret[0 .. m_count] = m_array[m_head .. m_head + m_count];
            } else {
                ret[0 .. m_array.length - m_head] = m_array[m_head .. $];
                ret[m_array.length - m_head .. m_array.length - m_head + m_tail] = m_array[0 .. m_tail];
            }
        }

        return ret;
    }

    void TrimExcess() {
        if (m_count < m_array.length * 0.9)
            SetCapacity(m_count);
    }

    private void SetCapacity(long capacity) {
        T[] newArray = new T[capacity];
        if (m_count) {
            if (m_head < m_tail) {
                newArray[0 .. m_count] = m_array[m_head .. m_head + m_count];
            } else {
                newArray[0 .. m_array.length - m_head] = m_array[m_head .. $];
                newArray[m_array.length - m_head .. m_array.length - m_head + m_tail] = m_array[0 .. m_tail];
            }
        }

        delete m_array;
        m_array = newArray;
        m_head  = 0;
        m_tail  = m_count == capacity ? 0 : m_count;
    }
}

synchronized class SafeQueue(T) : Queue!T { }