/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module Library.List;

import core.vararg;


private T min(T)(T a, T b) {
	return a < b ? a : b;
}


class List(T) {
    alias scope int delegate(ref T) ForeachDelegate;
    alias scope int delegate(ulong, ref T) LongForeachDelegate;
	
    private T[] m_array;
    private long m_count;

	long count() const {
		return m_count;
	}
	
	long capacity() const {
		return m_array.length;
	}

    T opIndex(long index) {
        return m_array[index];
    }

    T[] opSlice(long start, long end) {
        return m_array[start .. end];
    }

    long opDollar() {
        return Count;
    }
    
    void opIndexAssign(T value, long index, ...) {
        m_array[index] = value; //TODO varargs
    }

    void opSliceAssign(T value, long start, long end) {
        m_array[start .. end] = value;
    }

    int opApply(ForeachDelegate dg) {
        return opApply((ulong, ref T x) => dg(x));
    }

    int opApply(LongForeachDelegate dg) {
        int result;
        
        for (ulong i = 0; i < Count; i++) {
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
        //foreach (x; m_array) TODO
            //delete x;

        //delete m_array;
    }
        
    void add(T item) {
        if (count == capacity)
            expand();
        
        m_array[m_count++] = item;
    }
    
    void addRange(List!T other) in {
        if (other is null)
            assert(false);
    } body {
        long tmp = other.m_array.length + capacity;
        while (capacity < tmp)
            expand();
        
        m_array[m_count .. (m_count + other.m_count)] = other.m_array[0 .. $];
        m_count += other.m_count;
    }
    
    void clear() {
        //foreach (x; m_array) TODO
            //delete x;

        m_array[] = null;
        m_count   = 0;
    }
    
    bool contains(T item) const {
        for (long i = 0; i < m_count; i++)
            if (m_array[i] == item)
                return true;
        
        return false;
    }

    void copyTo(T[] array, long index) {
        auto m = min(index + array.length, m_count);
        array[0 .. m - index] = m_array[index .. m];
    }
    
    bool remove(T item) {
        long idx = indexOf(item);
        if (idx == -1) {
            return false;
		}
        
        removeAt(idx);
        return true;
    }
    
    void removeAt(long index) in {
        if (index < 0 || index > m_count)
            assert(false);
    } body {        
        m_array[index .. m_count - 1] = m_array[index + 1 .. m_count];
        m_count--;
    }
    
    void removeRange(long index, long count) in {
        if (count < 0 || index < 0)
            assert(false);
        
        if (m_count < count - index || m_count < index)
            assert(false);
    } body {
        m_array[index .. $] = m_array[index + count .. $];
        m_count -= count;
    }
    
    void reverse() {
        for (long i = 0; i < m_count; i++) {
            T tmp = m_array[i];
            m_array[i] = m_array[m_count - i];
            m_array[m_count - i] = tmp;
        }
    }
    
    void reverse(long index, long count) in {
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
    
    long indexOf(T item) {
        foreach (i; 0 .. m_count)
            if (m_array[i] == item)
                return i;
        
        return -1;
    }

    void insert(long index, T item) {
        if (count == capacity)
            expand();

        m_array[index + 1 .. m_count] = m_array[index .. m_count];
        m_array[index] = item;
    }

    T[] toArray() {
        auto ret = new T[count];
        ret[]    = m_array;

        return ret;
    }

    private void expand() {
        T[] newArray = new T[capacity * 2];
        newArray[0 .. m_array.length] = m_array[0 .. $];
        
        delete m_array;
        m_array = newArray;
    }
}
