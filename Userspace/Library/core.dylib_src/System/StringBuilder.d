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

module System.StringBuilder;

import System;
import System.Collections;


class StringBuilder {
    static const long DefaultCapacity = 16;
    List!string m_list;

    @property {
        long Length() {
            long ret;
            foreach (x; m_list)
                ret += x.length;

            return ret;
        }
    }

    this(long capacity = DefaultCapacity) {
        m_list = new List!string(capacity);
    }

    this(string value) {
        this();
        Append(value);
    }

    this(string[] values) {
        this(values.length > DefaultCapacity ? values.length : DefaultCapacity);

        foreach (x; values)
            Append(x);
    }

    ~this() {
        foreach (x; m_list)
            delete x;

        delete m_list;
    }

    void Append(T)(T value) {
        m_list.Add(value.To!string());
    }

    void Insert(T)(long index, T value) {
        //TODO: Implement Insert in List
    }

    void Remove(long start, long length) {
        //TODO: implement this LOL
    }

    void Clear() {
        foreach (x; m_list)
            delete x;

        m_list.Clear();
    }

    string ToString() {
        auto ret = new char[Length];

        long p;
        foreach (x; m_list) {
            ret[p .. x.length] = x;
            p += x.length;
        }

        return cast(string)ret;
    }
}