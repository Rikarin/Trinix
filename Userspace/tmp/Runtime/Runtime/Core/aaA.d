/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix
 * Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 * Matsumoto Satoshi <satoshi@gshost.eu>
 * 
 * TODO: FIXXXX
 */
module Runtime.Core.aaA;

import Runtime.Utilities.Memory;


private Entry*[] newBuckets(in size_t len) @trusted pure nothrow
{
    auto ptr = cast(Entry **)GC.calloc(len * (Entry *).sizeof, GC.BlkAttr.NO_INTERIOR);
    return ptr[0..len];
}

// Auto-rehash and pre-allocate - Dave Fladebo
static immutable size_t[] prime_list = [
    31UL,
    97UL,            389UL,
    1_543UL,          6_151UL,
    24_593UL,         98_317UL,
    393_241UL,      1_572_869UL,
    6_291_469UL,     25_165_843UL,
    100_663_319UL,    402_653_189UL,
    1_610_612_741UL,  4_294_967_291UL,
    //  8_589_934_513UL, 17_179_869_143UL
];

/* This is the type of the return value for dynamic arrays.
 * It should be a type that is returned in registers.
 * Although DMD will return types of Array in registers,
 * gcc will not, so we instead use a 'long'.
 */
alias void[] ArrayRet_t;

struct Array {
    size_t length;
    void* ptr;
}

struct Entry {
    Entry* next;
    size_t hash;
    /* key   */
    /* value */
}

struct Impl {
    Entry*[] buckets;
    size_t nodes;       // total number of entries
    TypeInfo _keyti;
    Entry*[4] binit;    // initial value of buckets[]
    
    @property const(TypeInfo) keyti() const @safe pure nothrow @nogc {
        return _keyti;
    }
}

/* This is the type actually seen by the programmer, although
 * it is completely opaque.
 */
struct AA {
    Impl* impl;
}

/**********************************
 * Align to next pointer boundary, so that
 * GC won't be faced with misaligned pointers
 * in value.
 */
size_t aligntsize(in size_t tsize) @safe pure nothrow @nogc {
    version (D_LP64) { //TODO ???
        // align to 16 bytes on 64-bit
        return (tsize + 15) & ~(15);
    }
    else {
        return (tsize + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
    }
}

extern (C):
/****************************************************
 * Determine number of entries in associative array.
 */
size_t _aaLen(in AA aa) pure nothrow @nogc out(result) {
    size_t len = 0;
    
    if (aa.impl) {
        foreach (const(Entry)* e; aa.impl.buckets) {
            while (e) {   len++;
                e = e.next;
            }
        }
    }

    assert(len == result);
} body {
    return aa.impl ? aa.impl.nodes : 0;
}

/*************************************************
 * Get pointer to value in associative array indexed by key.
 * Add entry for key if it is not already there.
 */
void* _aaGetX(AA* aa, const TypeInfo keyti, in size_t valuesize, in void* pkey) in {
    assert(aa);
} out (result) {
    assert(result);
    assert(aa.impl !is null);
    assert(aa.impl.buckets.length);
} body {
    size_t i;
    Entry *e;
    immutable keytitsize = keyti.TSize;
    
    if (aa.impl is null) {
        aa.impl = new Impl();
        aa.impl.buckets = aa.impl.binit[];
    }

    aa.impl._keyti = cast()keyti;    
    auto key_hash = keyti.getHash(pkey);

    i = key_hash % aa.impl.buckets.length;
    auto pe = &aa.impl.buckets[i];

    while ((e = *pe) !is null) {
        if (key_hash == e.hash) {
            if (keyti.Equals(pkey, e + 1))
                goto Lret;
        }
        pe = &e.next;
    }
    
    {
        // Not found, create new elem
        size_t size = Entry.sizeof + aligntsize(keytitsize) + valuesize;
        e = cast(Entry *)GC.malloc(size);
        e.next = null;
        e.hash = key_hash;
        ubyte* ptail = cast(ubyte*)(e + 1);
        memcpy(ptail, pkey, keytitsize);
        memset(ptail + aligntsize(keytitsize), 0, valuesize); // zero value
        *pe = e;
        
        auto nodes = ++aa.impl.nodes;
        if (nodes > aa.impl.buckets.length * 4) {
            _aaRehash(aa,keyti);
        }
    }
    
Lret:
    return cast(void *)(e + 1) + aligntsize(keytitsize);
}

/*************************************************
 * Get pointer to value in associative array indexed by key.
 * Returns null if it is not already there.
 */
inout(void)* _aaGetRvalueX(inout AA aa, in TypeInfo keyti, in size_t valuesize, in void* pkey) {
    if (aa.impl is null)
        return null;
    
    auto keysize = aligntsize(keyti.TSize);
    auto len = aa.impl.buckets.length;
    
    if (len) {
        auto key_hash = keyti.getHash(pkey);
        size_t i = key_hash % len;
        inout(Entry)* e = aa.impl.buckets[i];

        while (e !is null) {
            if (key_hash == e.hash) {
                if (keyti.Equals(pkey, e + 1))
                    return cast(inout void *)(e + 1) + keysize;
            }
            e = e.next;
        }
    }
    return null;    // not found, caller will throw exception
}

/*************************************************
 * Determine if key is in aa.
 * Returns:
 *      null    not in aa
 *      !=null  in aa, return pointer to value
 */
inout(void)* _aaInX(inout AA aa, in TypeInfo keyti, in void* pkey) {
    if (aa.impl) {
        auto len = aa.impl.buckets.length;
        
        if (len) {
            auto key_hash = keyti.getHash(pkey);
            const i = key_hash % len;
            inout(Entry)* e = aa.impl.buckets[i];

            while (e !is null) {
                if (key_hash == e.hash) {
                    if (keyti.Equals(pkey, e + 1))
                        return cast(inout void *)(e + 1) + aligntsize(keyti.TSize);
                }
                e = e.next;
            }
        }
    }
   
    return null;
}

/*************************************************
 * Delete key entry in aa[].
 * If key is not in aa[], do nothing.
 */
bool _aaDelX(AA aa, in TypeInfo keyti, in void* pkey) {
    Entry *e;
    
    if (aa.impl && aa.impl.buckets.length) {
        auto key_hash = keyti.getHash(pkey);

        size_t i = key_hash % aa.impl.buckets.length;
        auto pe = &aa.impl.buckets[i];
        while ((e = *pe) !is null) {
            if (key_hash == e.hash) {
                if (keyti.Equals(pkey, e + 1)) {
                    *pe = e.next;
                    aa.impl.nodes--;
                    GC.free(e);
                    return true;
                }
            }
            pe = &e.next;
        }
    }
    return false;
}

/********************************************
 * Produce array of values from aa.
 */
inout(ArrayRet_t) _aaValues(inout AA aa, in size_t keysize, in size_t valuesize) pure nothrow {
    size_t resi;
    Array a;
    
    auto alignsize = aligntsize(keysize);
    
    if (aa.impl !is null) {
        a.length = _aaLen(aa);
        a.ptr = cast(byte *) GC.malloc(a.length * valuesize, valuesize < (void *).sizeof ? GC.BlkAttr.NO_SCAN : 0);
        resi = 0;

        foreach (inout(Entry)* e; aa.impl.buckets) {
            while (e) {
                memcpy(a.ptr + resi * valuesize, cast(byte *)e + Entry.sizeof + alignsize, valuesize);
                resi++;
                e = e.next;
            }
        }
        assert(resi == a.length);
    }
    return *cast(inout ArrayRet_t*)(&a);
}

/********************************************
 * Rehash an array.
 */
void* _aaRehash(AA* paa, in TypeInfo keyti) pure nothrow {
    if (paa.impl !is null) {
        auto len = _aaLen(*paa);

        if (len) {
            Impl newImpl;
            Impl* oldImpl = paa.impl;
            
            size_t i;
            for (i = 0; i < prime_list.length - 1; i++)
                if (len <= prime_list[i])
                    break;

            len = prime_list[i];
            newImpl.buckets = newBuckets(len);
            
            foreach (e; oldImpl.buckets) {
                while (e) {
                    auto enext = e.next;
                    const j = e.hash % len;

                    e.next = newImpl.buckets[j];
                    newImpl.buckets[j] = e;
                    e = enext;
                }
            }

            if (oldImpl.buckets.ptr == oldImpl.binit.ptr)
                oldImpl.binit[] = null;
            else
                GC.free(oldImpl.buckets.ptr);
            
            newImpl.nodes = oldImpl.nodes;
            newImpl._keyti = oldImpl._keyti;
            
            *paa.impl = newImpl;
        } else {
            if (paa.impl.buckets.ptr != paa.impl.binit.ptr)
                GC.free(paa.impl.buckets.ptr);

            paa.impl.buckets = paa.impl.binit[];
        }
    }
    return (*paa).impl;
}

/********************************************
 * Produce array of N byte keys from aa.
 */
inout(ArrayRet_t) _aaKeys(inout AA aa, in size_t keysize) pure nothrow {
    auto len = _aaLen(aa);
    if (!len)
        return null;
    
    immutable blkAttr = !(aa.impl.keyti.Flags & 1) ? GC.BlkAttr.NO_SCAN : 0;
    auto res = (cast(byte *) GC.malloc(len * keysize, blkAttr))[0 .. len * keysize];
    
    size_t resi = 0;
    foreach (inout(Entry)* e; aa.impl.buckets) {
        while (e) {
            memcpy(&res[resi * keysize], cast(byte *)(e + 1), keysize);
            resi++;
            e = e.next;
        }
    }
    assert(resi == len);
    
    Array a;
    a.length = len;
    a.ptr = res.ptr;
    return *cast(inout ArrayRet_t *)(&a);
}

/**********************************************
 * 'apply' for associative arrays - to support foreach
 */
// dg is D, but _aaApply() is C
extern (D) alias int delegate(void *) dg_t;

int _aaApply(AA aa, in size_t keysize, dg_t dg) {
    if (aa.impl is null)
        return 0;
    
    immutable alignsize = aligntsize(keysize);
    foreach (e; aa.impl.buckets) {
        while (e) {
            auto result = dg(cast(void *)(e + 1) + alignsize);
            if (result)
                return result;
            e = e.next;
        }
    }
    return 0;
}

// dg is D, but _aaApply2() is C
extern (D) alias int delegate(void *, void *) dg2_t;

int _aaApply2(AA aa, in size_t keysize, dg2_t dg) {
    if (aa.impl is null)
        return 0;

    immutable alignsize = aligntsize(keysize);
    foreach (e; aa.impl.buckets) {
        while (e) {
            auto result = dg(e + 1, cast(void *)(e + 1) + alignsize);
            if (result)
                return result;
            e = e.next;
        }
    }
    
    return 0;
}

/***********************************
 * Construct an associative array of type ti from
 * length pairs of key/value pairs.
 */
Impl* _d_assocarrayliteralTX(const TypeInfo_AssociativeArray ti, void[] keys, void[] values) {
    const valuesize = ti.Next.TSize;             // value size
    const keyti = ti.key;
    const keysize = keyti.TSize;                 // key size
    const length = keys.length;
    Impl* result;

    assert(length == values.length);
    if (length == 0 || valuesize == 0 || keysize == 0) {
    } else {
        result = new Impl();
        result._keyti = cast() keyti;
        
        size_t i;
        for (i = 0; i < prime_list.length - 1; i++) {
            if (length <= prime_list[i])
                break;
        }
        auto len = prime_list[i];
        result.buckets = newBuckets(len);
        
        size_t keytsize = aligntsize(keysize);
        
        for (size_t j = 0; j < length; j++) {
            auto pkey = keys.ptr + j * keysize;
            auto pvalue = values.ptr + j * valuesize;
            Entry* e;
            
            auto key_hash = keyti.getHash(pkey);
            i = key_hash % len;
            auto pe = &result.buckets[i];
            while (1) {
                e = *pe;
                if (!e) {
                    // Not found, create new elem
                    e = cast(Entry *) cast(void*) new void[Entry.sizeof + keytsize + valuesize];
                    memcpy(e + 1, pkey, keysize);
                    e.hash = key_hash;
                    *pe = e;
                    result.nodes++;
                    break;
                }
                if (key_hash == e.hash) {
                    if (keyti.Equals(pkey, e + 1))
                        break;
                }
                pe = &e.next;
            }
            memcpy(cast(void *)(e + 1) + keytsize, pvalue, valuesize);
        }
    }
    return result;
}


const(TypeInfo_AssociativeArray) _aaUnwrapTypeInfo(const(TypeInfo) tiRaw) pure nothrow @nogc {
    const(TypeInfo)* p = &tiRaw;
    TypeInfo_AssociativeArray ti;

    while (true) {
        if ((ti = cast(TypeInfo_AssociativeArray)*p) !is null)
            break;
        
        if (auto tiConst = cast(TypeInfo_Const)*p) {
            // The member in object_.d and object.di differ. This is to ensure
            //  the file can be compiled both independently in unittest and
            //  collectively in generating the library. Fixing object.di
            //  requires changes to std.format in Phobos, fixing object_.d
            //  makes Phobos's unittest fail, so this hack is employed here to
            //  avoid irrelevant changes.
            static if (is(typeof(&tiConst.base) == TypeInfo*))
                p = &tiConst.base;
            else
                p = &tiConst.next;
        } else
            assert(0);  // ???
    }
    
    return ti;
}


/***********************************
 * Compare AA contents for equality.
 * Returns:
 *      1       equal
 *      0       not equal
 */
int _aaEqual(in TypeInfo tiRaw, in AA e1, in AA e2) {
    if (e1.impl is e2.impl)
        return 1;
    
    size_t len = _aaLen(e1);
    if (len != _aaLen(e2))
        return 0;

    if (e1.impl is null || e2.impl is null)
        return 1;

    const TypeInfo_AssociativeArray ti = _aaUnwrapTypeInfo(tiRaw);    
    const keyti = ti.key;
    const valueti = ti.next;
    const keysize = aligntsize(keyti.TSize);
    
    assert(e2.impl !is null);
    const len2 = e2.impl.buckets.length;
    
    int _aaKeys_x(const(Entry)* e) {
        do {
            auto pkey = cast(void*)(e + 1);
            auto pvalue = pkey + keysize;
            
            auto key_hash = keyti.getHash(pkey);
            const i = key_hash % len2;
            const(Entry)* f = e2.impl.buckets[i];
            while (1) {
                if (f is null)
                    return 0;                   // key not found, so AA's are not equal
                if (key_hash == f.hash) {
                    if (keyti.Equals(pkey, f + 1)) {
                        auto pvalue2 = cast(void *)(f + 1) + keysize;
                        if (valueti.Equals(pvalue, pvalue2))
                            break;
                        else
                            return 0;           // values don't match, so AA's are not equal
                    }
                }
                f = f.next;
            }
            
            // Look at next entry in e1
            e = e.next;
        } while (e !is null);
        return 1;                       // this subtree matches
    }
    
    foreach (e; e1.impl.buckets) {
        if (e) {
            if (_aaKeys_x(e) == 0)
                return 0;
        }
    }
    
    return 1;           // equal
}

/*****************************************
 * Computes a hash value for the entire AA
 * Returns:
 *      Hash value
 */
ulong _aaGetHash(in AA* aa, in TypeInfo tiRaw) nothrow {
    import Runtime.Utilities.Hash;
    
    if (aa.impl is null)
        return 0;
    
    ulong h = 0;
    const TypeInfo_AssociativeArray ti = _aaUnwrapTypeInfo(tiRaw);
    const keyti = ti.key;
    const valueti = ti.next;
    const keysize = aligntsize(keyti.TSize);
    
    foreach (const(Entry)* e; aa.impl.buckets) {
        while (e) {
            auto pkey = cast(void*)(e + 1);
            auto pvalue = pkey + keysize;
            
            // Compute a hash for the key/value pair by hashing their
            // respective hash values.
            ulong[2] hpair;
            hpair[0] = e.hash;
            hpair[1] = valueti.getHash(pvalue);
            
            // Combine the hash of the key/value pair with the running hash
            // value using an associative operator (+) so that the resulting
            // hash value is independent of the actual order the pairs are
            // stored in (important to ensure equality of hash value for two
            // AA's containing identical pairs but with different hashtable
            // sizes).
            h += hashOf(hpair.ptr, hpair.length * ulong.sizeof);
            
            e = e.next;
        }
    }
    
    return h;
}

/**
 * _aaRange implements a ForwardRange
 */
struct Range {
    Impl* impl;
    Entry* current;
}

Range _aaRange(AA aa) pure nothrow @nogc {
    typeof(return) res;
    if (aa.impl is null)
        return res;
    
    res.impl = aa.impl;
    foreach (entry; aa.impl.buckets) {
        if (entry !is null) {
            res.current = entry;
            break;
        }
    }
    return res;
}

bool _aaRangeEmpty(Range r) pure nothrow @nogc {
    return r.current is null;
}

void* _aaRangeFrontKey(Range r) pure nothrow @nogc in {
    assert(r.current !is null);
} body {
    return cast(void*)r.current + Entry.sizeof;
}

void* _aaRangeFrontValue(Range r) pure nothrow @nogc in {
    assert(r.current !is null);
    assert(r.impl.keyti !is null); // set on first insert
} body {
    return cast(void*)r.current + Entry.sizeof + aligntsize(r.impl.keyti.TSize);
}

void _aaRangePopFront(ref Range r) pure nothrow @nogc {
    if (r.current.next !is null)
        r.current = r.current.next;
    else {
        immutable idx = r.current.hash % r.impl.buckets.length;
        r.current = null;
        foreach (entry; r.impl.buckets[idx + 1 .. $]) {
            if (entry !is null) {
                r.current = entry;
                break;
            }
        }
    }
}