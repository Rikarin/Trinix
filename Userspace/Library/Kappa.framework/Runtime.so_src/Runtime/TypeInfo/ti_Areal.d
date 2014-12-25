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
module Runtime.TypeInfo.ti_Areal;

import Runtime.Utilities.Hash;
import Runtime.TypeInfo.ti_real;


class TypeInfo_Ae : TypeInfo_Array { /* real[] */
    override bool opEquals(Object o) {
        return TypeInfo.opEquals(o);
    }
    
    override string ToString() const {
        return "real[]";
    }
    
    override size_t GetHash(in void* p) @trusted const {
        real[] s = *cast(real[] *)p;
        return HashOf(s.ptr, s.length * real.sizeof);
    }
    
    override bool Equals(in void* p1, in void* p2) const {
        real[] s1 = *cast(real[] *)p1;
        real[] s2 = *cast(real[] *)p2;
        size_t len = s1.length;
        
        if (len != s2.length)
            return false;

        for (size_t u = 0; u < len; u++) {
            if (!TypeInfo_e._equals(s1[u], s2[u]))
                return false;
        }
        return true;
    }
    
    override int Compare(in void* p1, in void* p2) const {
        real[] s1 = *cast(real[] *)p1;
        real[] s2 = *cast(real[] *)p2;
        size_t len = s1.length;
        
        if (s2.length < len)
            len = s2.length;

        for (size_t u = 0; u < len; u++) {
            int c = TypeInfo_e._compare(s1[u], s2[u]);
            if (c)
                return c;
        }

        if (s1.length < s2.length)
            return -1;
        else if (s1.length > s2.length)
            return 1;
        return 0;
    }
    
    override @property inout(TypeInfo) Next() inout {
        return cast(inout)typeid(real);
    }
}

class TypeInfo_Aj : TypeInfo_Ae { /* ireal[] */
    override string ToString() const {
        return "ireal[]";
    }
    
    override @property inout(TypeInfo) Next() inout {
        return cast(inout)typeid(ireal);
    }
}