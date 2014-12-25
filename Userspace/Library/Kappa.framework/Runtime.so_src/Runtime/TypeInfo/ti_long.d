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
 * http://bit.ly/1wIYh3A and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 * Matsumoto Satoshi <satoshi@gshost.eu>
 */
module Runtime.TypeInfo.ti_long;

import Runtime.Utilities.Hash;


class TypeInfo_l : TypeInfo { /* long */
@trusted:
const:
pure:
nothrow:
    
    override string ToString() const pure nothrow @safe {
        return "long";
    }
    
    override size_t GetHash(in void* p) {
        return HashOf(p, ulong.sizeof);
    }
    
    override bool Equals(in void* p1, in void* p2) {
        return *cast(ulong *)p1 == *cast(ulong *)p2;
    }
    
    override int Compare(in void* p1, in void* p2) {
        if (*cast(ulong *)p1 < *cast(ulong *)p2)
            return -1;
        else if (*cast(ulong *)p1 > *cast(ulong *)p2)
            return 1;
        return 0;
    }
    
    override @property size_t TSize() nothrow pure {
        return ulong.sizeof;
    }
    
    override void Swap(void *p1, void *p2) {
        ulong t;
        
        t = *cast(ulong *)p1;
        *cast(ulong *)p1 = *cast(ulong *)p2;
        *cast(ulong *)p2 = t;
    }
    
    override @property size_t TAlign() nothrow pure {
        return ulong.alignof;
    }
}