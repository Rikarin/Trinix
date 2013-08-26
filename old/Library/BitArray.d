/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Library.BitArray;


final class BitArray {
    private ulong[] m_bits;
    private long m_minimal;
    
    private long IndexFromBit(long bit)  { return bit / 64; }
    private long OffsetFromBit(long bit) { return bit % 64; }
    private long IndexFromByte(long b)   { return b / 8;    }
    private long OffsetFromByte(long b)  { return b % 8;    }
    private long IndexFromInt(long i)    { return i / 2;    }
    private long OffsetFromInt(long i)   { return i % 2;    }

    @property long Count() {
        return m_bits.length * 64;
    }
    
    void opIndexAssign(bool value, long index) {
        Set(index, value);
    }
    
    bool opIndex(long index) {
        return Get(index);
    }

    this(BitArray bits) in {
        assert(bits);
    } body {
        m_bits = new ulong[bits.m_bits.length];
        foreach (long i, x; bits.m_bits)
            m_bits[i] = x;
    }
    
    this(bool[] bits) in {
        assert (bits);
    } body {
        m_bits = new ulong[IndexFromBit(bits.length) + 1];
        
        foreach (i; 0 .. bits.length)
            m_bits[IndexFromBit(i)] = bits[i];
    }

    this(long count) in {
        assert(count);
    } body {        
        m_bits = new ulong[IndexFromBit(count) + 1];
    }
    
    this(long count, bool value) in {
        assert(count);
    } body {
        m_bits = new ulong[IndexFromBit(count) + 1];
        SetAll(value);
    }
        
    ~this() {
        delete m_bits;
    }
    
    
    BitArray Not() {
        foreach (i; 0 .. m_bits.length)
            m_bits[i] = ~m_bits[i];

        m_minimal = 0;
        return this;
    }
    
    BitArray Or(BitArray value) in {
        assert(value);
        assert(Count == value.Count);
    } body {
        foreach (i; 0 .. m_bits.length)
            m_bits[i] |= value.m_bits[i];

        m_minimal = 0;
        return this;
    }
    
    BitArray Xor(BitArray value) in {
        assert(value);
        assert(Count == value.Count);
    } body {
        foreach (i; 0 .. m_bits.length)
            m_bits[i] ^= value.m_bits[i];

        m_minimal = 0;
        return this;
    }
    
    BitArray And(BitArray value) in {
        assert(value);
        assert(Count == value.Count);
    } body {
        foreach (i; 0 .. m_bits.length)
            m_bits[i] &= value.m_bits[i];

        m_minimal = 0;
        return this;
    }
    
    void Set(long index, bool value) in {
        //assert(index > 0 && index < Count); TODO
    } body {
        if (value)
            m_bits[IndexFromBit(index)] |= (1UL << OffsetFromBit(index));
        else {
            m_bits[IndexFromBit(index)] &= ~(1UL << OffsetFromBit(index));
            m_minimal = IndexFromBit(index);
        }
    }
    
    void SetAll(bool value) {
        foreach (i; 0 .. m_bits.length)
            m_bits[i] = value ? 0xFFFF_FFFF_FFFF_FFFF : 0;

        m_minimal = 0;
    }
    
    bool Get(long index) in {
        assert(index > 0 && index < Count);
    } body {
        return (m_bits[IndexFromBit(index)] & (1UL << OffsetFromBit(index))) != 0;
    }
    
    long FirstFreeBit() {
        foreach (i; m_minimal .. m_bits.length) {
            if (m_bits[i] != 0xFFFF_FFFF_FFFF_FFFF) {
                foreach(j; 0 .. 64) {
                    if (!(m_bits[i] & (1UL << j)))
                        return i * 64 + j;
                }
            } else
                m_minimal = i;
        }

        return -1;
    }
}