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
module Runtime.TypeInfo.ti_AC;


class TypeInfo_AC : TypeInfo_Array {
    override string ToString() const {
        return TypeInfo.ToString();
    }
    
    override bool opEquals(Object o) {
        return TypeInfo.opEquals(o);
    }
    
    override size_t GetHash(in void* p) @trusted const {
        Object[] s = *cast(Object[]*)p;
        size_t hash = 0;
        
        foreach (Object o; s) {
            if (o)
                hash += o.GetHashCode();
        }
        return hash;
    }
    
    override bool Equals(in void* p1, in void* p2) const {
        Object[] s1 = *cast(Object[] *)p1;
        Object[] s2 = *cast(Object[] *)p2;
        
        if (s1.length == s2.length) {
            for (size_t u = 0; u < s1.length; u++) {
                Object o1 = s1[u];
                Object o2 = s2[u];
                
                // Do not pass null's to Object.opEquals()
                if (o1 is o2 ||
                    (!(o1 is null) && !(o2 is null) && o1.opEquals(o2)))
                    continue;
                return false;
            }
            return true;
        }
        return false;
    }
    
    override int Compare(in void* p1, in void* p2) const {
        Object[] s1 = *cast(Object[] *)p1;
        Object[] s2 = *cast(Object[] *)p2;
        auto     c  = cast(long)(s1.length - s2.length);

        if (c == 0) {
            for (size_t u = 0; u < s1.length; u++) {
                Object o1 = s1[u];
                Object o2 = s2[u];
                
                if (o1 is o2)
                    continue;
                
                // Regard null references as always being "less than"
                if (o1) {
                    if (!o2)
                        return 1;
                    c = o1.opCmp(o2);
                    if (c == 0)
                        continue;
                    break;
                } else
                    return -1;
            }
        }
        return c < 0 ? -1 : c > 0 ? 1 : 0;
    }
    
    override @property inout(TypeInfo) Next() inout {
        return cast(inout)typeid(Object);
    }
}