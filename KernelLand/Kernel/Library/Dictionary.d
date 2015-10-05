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

module Library.Dictionary;

import Library;


class Dictionary(TKey, TValue) {
    List!TKey m_keys;
    List!TValue m_values;


    this() {
        m_keys   = new List!TKey();
        m_values = new List!TValue();
    }

    ~this() {
        delete m_keys;
        delete m_values;
    }

    TValue opIndex(TKey key) {
        long index = m_keys.IndexOf(key);
        if (index == -1)
            return cast(TValue)0;

        return m_values[index];
    }

    void opIndexAssign(TValue value, TKey key) {
        long index = m_keys.IndexOf(key);

        if (index == -1) {
            m_keys.Add(key);
            m_values.Add(value);
        } else {
            m_values[index] = value;
        }
    }

    bool Remove(TKey key) {
        long index = m_keys.IndexOf(key);
        if (index == -1)
            return false;

        m_keys.RemoveAt(index);
        m_values.RemoveAt(index);
        return true;
    }
}