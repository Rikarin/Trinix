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
module Runtime.TypeInfo.ti_delegate;

import Runtime.Utilities.Hash;


alias void delegate(int) dg;

class TypeInfo_D : TypeInfo { /* delegate */
@trusted:
const:
pure:
nothrow:
    override size_t GetHash(in void* p) {
        return HashOf(p, dg.sizeof);
    }
    
    override bool Equals(in void* p1, in void* p2) {
        return *cast(dg *)p1 == *cast(dg *)p2;
    }
    
    override @property size_t TSize() nothrow pure {
        return dg.sizeof;
    }
    
    override void Swap(void *p1, void *p2) {
        dg t;
        
        t = *cast(dg *)p1;
        *cast(dg *)p1 = *cast(dg *)p2;
        *cast(dg *)p2 = t;
    }
    
    override @property uint Flags() nothrow pure {
        return 1;
    }
}