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

module System.Collections.Stack;

import System;
import System.Collections;


class Stack(T) : IEnumerable!T {
    private T[] m_array;
    private long m_count;

    @property {
        long Count() const { return m_count; }
    }

    int opApply(ForeachDelegate dg) {
        return opApply((ulong, ref T x) => dg(x));
    }
    
    int opApply(LongForeachDelegate dg) {
        int result;
        
        for (ulong i = 0; i < m_array.length; i++) {
            result = dg(i, m_array[i]);
            if (result)
                break;
        }
        
        return result;
    }
    
    int opApplyReverse(ForeachDelegate dg) {
        return opApplyReverse((ulong, ref T x) => dg(x));
    }
    
    int opApplyReverse(LongForeachDelegate dg) {
        int result;
        
        for (long i = Count - 1; i >= 0; i--) {
            result = dg(i, m_array[i]);
            if (result)
                break;
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
        m_count   = 0;
    }

    bool Contains(T item) {
        foreach (x; m_array) {
            if (x == item)
                return true;
        }

        return false;
    }

    void CopyTo(T[] array, long index) {
        auto min = Math.Min(index + array.length, m_count);
        array[0 .. min - index] = m_array[index .. min];
    }

    T Peek() {
        if (!m_count)
            throw new InvalidOperationException();

        return m_array[m_count - 1];
    }

    T Pop() {
        if (!m_count)
            throw new InvalidOperationException();
        
        return m_array[--m_count];
    }

    void Push(T item) {
        if (m_count == m_array.length) {
            T[] newArray = new T[m_array.length * 2];
            newArray[0 .. m_array.length] = m_array;

            delete m_array;
            m_array = newArray;
        }

        m_array[m_count++] = item;
    }

    void TrimExcess() {
        if (m_count < m_array.length * 0.9) {
            T[] newArray = new T[m_count];
            newArray[]   = m_array[0 .. m_count];

            delete m_array;
            m_array = newArray;
        }
    }
}