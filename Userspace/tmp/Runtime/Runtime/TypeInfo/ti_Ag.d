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
module Runtime.TypeInfo.ti_Ag;

import Runtime.Utilities.Hash;
import Runtime.Utilities.Memory;


class TypeInfo_Ag : TypeInfo_Array { /* byte[] */
    override bool opEquals(Object o) {
        return TypeInfo.opEquals(o);
    }
    
    override string ToString() const {
        return "byte[]";
    }
    
    override size_t GetHash(in void* p) @trusted const {
        byte[] s = *cast(byte[] *)p;
        return HashOf(s.ptr, s.length * byte.sizeof);
    }
    
    override bool Equals(in void* p1, in void* p2) const {
        byte[] s1 = *cast(byte[] *)p1;
        byte[] s2 = *cast(byte[] *)p2;
        
        return s1.length == s2.length && memcmp(cast(byte *)s1, cast(byte *)s2, s1.length) == 0;
    }
    
    override int Compare(in void* p1, in void* p2) const {
        byte[] s1 = *cast(byte[] *)p1;
        byte[] s2 = *cast(byte[] *)p2;
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
        return cast(inout)typeid(byte);
    }
}

class TypeInfo_Ah : TypeInfo_Ag { /* ubyte[] */
    override string ToString() const {
        return "ubyte[]";
    }
    
    override int Compare(in void* p1, in void* p2) const {
        char[] s1 = *cast(char[] *)p1;
        char[] s2 = *cast(char[] *)p2;
        
        return 0; //TODO: dstrcmp(s1, s2);
    }
    
    override @property inout(TypeInfo) Next() inout {
        return cast(inout)typeid(ubyte);
    }
}

class TypeInfo_Av : TypeInfo_Ah { /* void[] */
    override string ToString() const {
        return "void[]";
    }
    
    override @property inout(TypeInfo) Next() inout {
        return cast(inout)typeid(void);
    }
}

class TypeInfo_Ab : TypeInfo_Ah { /* bool[] */
    override string ToString() const {
        return "bool[]";
    }
    
    override @property inout(TypeInfo) Next() inout {
        return cast(inout)typeid(bool);
    }
}

class TypeInfo_Aa : TypeInfo_Ah { /* char[] */
    override string ToString() const {
        return "char[]";
    }
    
    override size_t GetHash(in void* p) @trusted const {
        char[] s = *cast(char[] *)p;
        size_t hash = 0;

        foreach (char c; s)
            hash = hash * 11 + c;

        return hash;
    }
    
    override @property inout(TypeInfo) Next() inout {
        return cast(inout)typeid(char);
    }
}

class TypeInfo_Aya : TypeInfo_Aa { /* string */
    override string ToString() const {
        return "string";
    }
    
    override @property inout(TypeInfo) Next() inout {
        return cast(inout)typeid(immutable(char));
    }
}

class TypeInfo_Axa : TypeInfo_Aa { /* const(char)[] */
    override string ToString() const {
        return "const(char)[]";
    }
    
    override @property inout(TypeInfo) Next() inout {
        return cast(inout)typeid(const(char));
    }
}