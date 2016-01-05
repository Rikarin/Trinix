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

module System.Collections.Dictionary;

import System;
import System.Collections;

import core.vararg;


class Dictionary(TKey, TValue) : IDictionary!(TKey, TValue) {
    alias scope int delegate(TKey, TValue) KeyValueForeachDelegate;

    private KeyValuePair!(TKey, TValue)[] m_array;
    private long m_count;

    @property {
        long Count()      const { return m_count; }
        bool IsReadOnly() const { return true;    }

        TKey[] Keys() {
            auto ret = new TKey[m_count];
            foreach (i, x; m_array)
                ret[i] = x.Key;

            return ret;
        }

        TValue[] Values() {
            auto ret = new TValue[m_count];
            foreach (i, x; m_array)
                ret[i] = x.Value;
            
            return ret;
        }
    }

    TValue opIndex(TKey index) {
        foreach (ref x; m_array[0 .. Count]) {
            if (x.Key == index)
                return x.Value;
        }

        return TValue.init; //TODO??
    }

    void opIndexAssign(TValue value, TKey index, ...) {
        foreach (i, x; m_array[0 .. Count]) {
            if (x.Key == index) {
                m_array[i] = KeyValuePair!(TKey, TValue)(index, value);
                return;
            }
        }

        //TODO varargs
    }

    int opApply(KeyValueForeachDelegate dg) {
        return opApply((ref KeyValuePair!(TKey, TValue) x) => dg(x.Key, x.Value));
    }

    int opApply(LongForeachDelegate dg) {
        throw new NotSupportedException();
    }

    int opApply(ForeachDelegate dg) {
        int result;
        
        for (ulong i = 0; i < Count; i++) {
            result = dg(m_array[i]);
            if (result)
                break;
        }
        
        return result;
    }

    int opApplyReverse(KeyValueForeachDelegate dg) {
        return opApplyReverse((ref KeyValuePair!(TKey, TValue) x) => dg(x.Key, x.Value));
    }

    int opApplyReverse(LongForeachDelegate dg) {
        throw new NotSupportedException();
    }

    int opApplyReverse(ForeachDelegate dg) {
        int result;
        
        for (long i = Count - 1; i >= 0; i--) {
            result = dg(m_array[i]);
            if (result)
                break;
        }
        
        return result;
    }

    this(long capacity = 4) in {
        assert(capacity > 0);
    } body {
        m_array = new KeyValuePair!(TKey, TValue)[capacity];
    }

    ~this() {
        //TODO: delete m_array;
    }

    void Add(TKey key, TValue value) {
         Add(KeyValuePair!(TKey, TValue)(key, value));
    }

    void Add(KeyValuePair!(TKey, TValue) item) {
        if (Count == m_array.length)
            Expand();

        m_array[m_count++] = item;
    }

    bool Remove(TKey key) {
        foreach (i, x; m_array) {
            if (x.Key == key) {
                m_array[i .. m_count] = m_array[i + 1 .. m_count];
                m_count--;
                return true;
            }
        }

        return false;
    }

    bool Remove(KeyValuePair!(TKey, TValue) item) {
        return Remove(item.Key);
    }

    bool Contains(TKey key) const {
        foreach (x; m_array) {
            if (x.Key == key)
                return true;
        }

        return false;
    }

    bool Contains(KeyValuePair!(TKey, TValue) item) const {
        foreach (x; m_array) {
            if (x == item)
                return true;
        }
        
        return false;
    }

    bool TryGetValue(TKey key, out TValue value) {
        value = this[key];
        if (value !is TValue.init) //??
            return true;

        return false;
    }

    void Clear() {
        m_array[] = null;
        m_count   = 0;
    }


    void CopyTo(KeyValuePair!(TKey, TValue)[] array, long index) {
        auto min = Math.Min(index + array.length, m_count);
        array[0 .. min - index] = m_array[index .. min];
    }

    private void Expand() {
        auto newArray = new KeyValuePair!(TKey, TValue)[m_array.length * 2];
        newArray[0 .. m_array.length] = m_array[0 .. $];
        
        delete m_array;
        m_array = newArray;
    }
}

synchronized class SafeDictionary(TKey, TValue) : Dictionary!(TKey, TValue) { }