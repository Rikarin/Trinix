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
module Runtime.TypeInfo.ti_ptr;

class TypeInfo_P : TypeInfo { /* pointer */
@trusted:
const:
pure:
nothrow:
    override size_t GetHash(in void* p) {
        return cast(uint)*cast(void* *)p;
    }
    
    override bool Equals(in void* p1, in void* p2) {
        return *cast(void* *)p1 == *cast(void* *)p2;
    }
    
    override int Compare(in void* p1, in void* p2) {
        auto c = *cast(void* *)p1 - *cast(void* *)p2;
        if (c < 0)
            return -1;
        else if (c > 0)
            return 1;
        return 0;
    }
    
    override @property size_t TSize() nothrow pure {
        return (void*).sizeof;
    }
    
    override void Swap(void *p1, void *p2) {
        void* t;
        
        t = *cast(void* *)p1;
        *cast(void* *)p1 = *cast(void* *)p2;
        *cast(void* *)p2 = t;
    }
    
    override @property uint Flags() nothrow pure {
        return 1;
    }
}