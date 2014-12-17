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
 */
module Runtime.TypeInfo.ti_ubyte;


class TypeInfo_h : TypeInfo { /* ubyte */
@trusted:
const:
pure:
nothrow:
    
    override string ToString() const pure nothrow @safe {
        return "ubyte";
    }
    
    override size_t GetHash(in void* p) {
        return *cast(ubyte *)p;
    }
    
    override bool Equals(in void* p1, in void* p2) {
        return *cast(ubyte *)p1 == *cast(ubyte *)p2;
    }
    
    override int Compare(in void* p1, in void* p2) {
        return *cast(ubyte *)p1 - *cast(ubyte *)p2;
    }
    
    override @property size_t TSize() nothrow pure {
        return ubyte.sizeof;
    }
    
    override void Swap(void *p1, void *p2) {
        ubyte t;
        
        t = *cast(ubyte *)p1;
        *cast(ubyte *)p1 = *cast(ubyte *)p2;
        *cast(ubyte *)p2 = t;
    }
}

class TypeInfo_b : TypeInfo_h { /* bool */
@trusted:
const:
pure:
nothrow:
    
    override string ToString() const pure nothrow @safe {
        return "bool";
    }
}