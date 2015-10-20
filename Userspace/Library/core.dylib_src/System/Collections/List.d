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

module System.Collections.List;


class List(T) {
    private T[] m_array;
    private long m_count;
    
    @property long Capacity()       { return m_array.length;  } 
    @property long Count()          { return m_count;         }
    long opDollar()                 { return m_count;         }
    ref T opIndex(long index)       { return m_array[index];  }
    T[] opSlice(long i, long j)     { return m_array[i .. j]; }
    
    int opApply(int delegate(ref T) dg) {
        int result;
        
        foreach (i; 0 .. m_count) {
            result = dg(m_array[i]);
            if (result)
                break;
        }
        
        return result;
    }
    
    int opApplyReverse(int delegate(ref T) dg) {
        int result;
        
        for (long i = m_count; i >= 0; i--) {
            result = dg(m_array[i]);
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
        //foreach (x; m_array)
            //delete x;

        delete m_array;
    }
    
    void Add(T item) {
        if (Count == Capacity)
            Resize();
        
        m_array[m_count++] = item;
    }
    
    void AddRange(List!T other) in {
        if (other is null)
            assert(false);
    } body {
        long tmp = other.m_array.length + Capacity;
        while (Capacity < tmp)
            Resize();
        
        m_array[m_count .. (m_count + other.m_count)] = other.m_array[0 .. $];
        m_count += other.m_count;
    }
    
    void Clear() {
        m_array[] = null;
        m_count   = 0;
    }
    
    bool Contains(T item) {
        for (long i = 0; i < m_count; i++)
            if (m_array[i] == item)
                return true;
        
        return false;
    }
    
    bool Remove(T item) {
        long idx = IndexOf(item);
        if (idx == -1)
            return false;
        
        RemoveAt(idx);
        return true;
    }
    
    void RemoveAt(long index) in {
        if (index < 0 || index > m_count)
            assert(false);
    } body {        
        m_array[index .. $] = m_array[index + 1 .. $];
        m_count--;
    }
    
    void RemoveRange(long index, long count) in {
        if (count < 0 || index < 0)
            assert(false);
        
        if (m_count < count - index || m_count < index)
            assert(false);
    } body {
        m_array[index .. $] = m_array[index + count .. $];
        m_count -= count;
    }
    
    void Reverse() {
        for (long i = 0; i < m_count; i++) {
            T tmp = m_array[i];
            m_array[i] = m_array[m_count - i];
            m_array[m_count - i] = tmp;
        }
    }
    
    void Reverse(long index, long count) in {
        if (index < 0 || count < 0)
            assert(false);
        
        if (m_count < count - index || m_count < index)
            assert(false);
    } body {
        for (long i = index; i < index + m_count; i++) {
            T tmp = m_array[i];
            m_array[i] = m_array[index + count - i];
            m_array[index + count - i] = tmp;
        }
    }
    
    long IndexOf(T item) {
        foreach (i; 0 .. m_count)
            if (m_array[i] == item)
                return i;
        
        return -1;
    }

    T[] ToArray() {
        return null; //TODO
    }
    
    private void Resize() {
        T[] newArray = new T[Capacity * 2];
        newArray[0 .. m_array.length] = m_array[0 .. $];
        
        delete m_array;
        m_array = newArray;
    }
}