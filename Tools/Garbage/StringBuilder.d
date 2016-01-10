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

module Library.StringBuilder;


final class StringBuilder {
    static const int DefaultCapacity = 16;
    static const int MaxChunkSize    = 8000;

    private char[] m_chars;
    private StringBuilder m_previous;
    private long m_length;
    private long m_offset;
    private long m_maxCapacity = 0;


    @property long Length()      { return m_offset + m_length;       }
    @property long Capacity()    { return m_offset + m_chars.length; }
    @property long MaxCapacity() { return m_maxCapacity;             }

    @property void Capacity(long value) {
        //TODO
    }

    this() {
        this(DefaultCapacity);
    }

    this(int capacity) {
        this(null, capacity);
    }

    this(string value) {
        this(value, DefaultCapacity);
    }

    this(string value, long capacity) {
        this(value, 0, value !is null ? value.length : 0, capacity);
    }

    this(string value, long startIndex, long length, long capacity) {
        //TODO: contracts

        if (value is null)
            value = "";

        if (startIndex > value.length - length)
        {} //TODO: throw...

        m_maxCapacity = long.max;
        if (!capacity)
            capacity = DefaultCapacity;

        if (capacity < length)
            capacity = length;

        m_chars  = new char[capacity];
        m_length = length;

        m_chars[0 .. value.length - startIndex] = value[startIndex .. $];
    }

    this(long capacity, long maxCapacity) {
        if (!capacity)
            capacity = DefaultCapacity < maxCapacity ? DefaultCapacity : maxCapacity;

        m_maxCapacity = maxCapacity;
        m_chars       = new char[capacity];
    }

    ~this() {
        delete m_chars;
    }

    void Append(string value) {
        //TODO
    }

    void Insert(long index, string value) {
        //TODO
    }

    string ToString() {
        return "TODO stirng";
        //TODO
    }
}