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
        assert(index > 0 && index < Count);
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