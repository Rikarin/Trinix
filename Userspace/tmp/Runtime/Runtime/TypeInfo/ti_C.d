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
module Runtime.TypeInfo.ti_C;


class TypeInfo_C : TypeInfo { /* Object */
@trusted:
const:
    override size_t GetHash(in void* p) {
        Object o = *cast(Object *)p;
        return o ? o.GetHashCode() : 0;
    }
    
    override bool Equals(in void* p1, in void* p2) {
        Object o1 = *cast(Object *)p1;
        Object o2 = *cast(Object *)p2;
        
        return o1 == o2;
    }
    
    override int Compare(in void* p1, in void* p2) {
        Object o1 = *cast(Object *)p1;
        Object o2 = *cast(Object *)p2;
        int c = 0;
        
        // Regard null references as always being "less than"
        if (!(o1 is o2)) {
            if (o1) {
                if (!o2)
                    c = 1;
                else
                    c = o1.opCmp(o2);
            } else
                c = -1;
        }
        return c;
    }
    
    override @property size_t TSize() nothrow pure {
        return Object.sizeof;
    }
    
    override @property uint Flags() nothrow pure {
        return 1;
    }
}