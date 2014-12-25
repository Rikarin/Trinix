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
module Runtime.TypeInfo.ti_Afloat;

import Runtime.Utilities.Hash;
import Runtime.TypeInfo.ti_float;


class TypeInfo_Af : TypeInfo_Array { /* float[] */
    override bool opEquals(Object o) {
        return TypeInfo.opEquals(o);
    }
    
    override string ToString() const {
        return "float[]";
    }
    
    override size_t GetHash(in void* p) @trusted const {
        float[] s = *cast(float[] *)p;
        return HashOf(s.ptr, s.length * float.sizeof);
    }
    
    override bool Equals(in void* p1, in void* p2) const {
        float[] s1 = *cast(float[] *)p1;
        float[] s2 = *cast(float[] *)p2;
        size_t len = s1.length;
        
        if (len != s2.length)
            return 0;

        for (size_t u = 0; u < len; u++) {
            if (!TypeInfo_f._equals(s1[u], s2[u]))
                return false;
        }
        return true;
    }
    
    override int Compare(in void* p1, in void* p2) const {
        float[] s1 = *cast(float[] *)p1;
        float[] s2 = *cast(float[] *)p2;
        size_t len = s1.length;
        
        if (s2.length < len)
            len = s2.length;

        for (size_t u = 0; u < len; u++) {
            int c = TypeInfo_f._compare(s1[u], s2[u]);
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
        return cast(inout)typeid(float);
    }
}

class TypeInfo_Ao : TypeInfo_Af { /* ifloat[] */
    override string ToString() const {
        return "ifloat[]";
    }
    
    override @property inout(TypeInfo) Next() inout {
        return cast(inout)typeid(ifloat);
    }
}