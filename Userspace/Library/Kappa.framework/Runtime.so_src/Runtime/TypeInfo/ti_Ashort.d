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
module Runtime.TypeInfo.ti_Ashort;

import Runtime.Utilities.Hash;
import Runtime.Utilities.Memory;


class TypeInfo_As : TypeInfo_Array { /* short[] */
    override bool opEquals(Object o) {
        return TypeInfo.opEquals(o);
    }
    
    override string ToString() const {
        return "short[]";
    }
    
    override size_t GetHash(in void* p) @trusted const {
        short[] s = *cast(short[] *)p;
        return HashOf(s.ptr, s.length * short.sizeof);
    }
    
    override bool Equals(in void* p1, in void* p2) const {
        short[] s1 = *cast(short[] *)p1;
        short[] s2 = *cast(short[] *)p2;
        
        return s1.length == s2.length && memcmp(cast(void *)s1, cast(void *)s2, s1.length * short.sizeof) == 0;
    }
    
    override int Compare(in void* p1, in void* p2) const {
        short[] s1 = *cast(short[] *)p1;
        short[] s2 = *cast(short[] *)p2;
        size_t len = s1.length;
        
        if (s2.length < len)
            len = s2.length;
        for (size_t u = 0; u < len; u++) {
            int result = s1[u] - s2[u];
            if (result)
                return result;
        }

        if (s1.length < s2.length)
            return -1;
        else if (s1.length > s2.length)
            return 1;
        return 0;
    }
    
    override @property inout(TypeInfo) Next() inout {
        return cast(inout)typeid(short);
    }
}

class TypeInfo_At : TypeInfo_As { /* ushort[] */
    override string ToString() const {
        return "ushort[]";
    }
    
    override int Compare(in void* p1, in void* p2) const {
        ushort[] s1 = *cast(ushort[] *)p1;
        ushort[] s2 = *cast(ushort[] *)p2;
        size_t len = s1.length;
        
        if (s2.length < len)
            len = s2.length;

        for (size_t u = 0; u < len; u++) {
            int result = s1[u] - s2[u];
            if (result)
                return result;
        }

        if (s1.length < s2.length)
            return -1;
        else if (s1.length > s2.length)
            return 1;
        return 0;
    }
    
    override @property inout(TypeInfo) Next() inout {
        return cast(inout)typeid(ushort);
    }
}

class TypeInfo_Au : TypeInfo_At { /* wchar[] */
    override string ToString() const {
        return "wchar[]";
    }
    
    override @property inout(TypeInfo) Next() inout {
        return cast(inout)typeid(wchar);
    }
}