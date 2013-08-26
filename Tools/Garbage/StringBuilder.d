/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
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