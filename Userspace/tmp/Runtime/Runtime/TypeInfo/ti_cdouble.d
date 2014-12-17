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
module Runtime.TypeInfo.ti_cdouble;

import Runtime.Utilities.Hash;



class TypeInfo_r : TypeInfo { /* cdouble */
@trusted:
pure:
nothrow:
    
    package static bool _equals(cdouble f1, cdouble f2) {
        return f1 == f2;
    }
    
    package static int _compare(cdouble f1, cdouble f2) {
        int result;
        
        if (f1.re < f2.re)
            result = -1;
        else if (f1.re > f2.re)
            result = 1;
        else if (f1.im < f2.im)
            result = -1;
        else if (f1.im > f2.im)
            result = 1;
        else
            result = 0;
        return result;
    }
    
const:
    override string ToString() const pure nothrow @safe {
        return "cdouble";
    }
    
    override size_t GetHash(in void* p) {
        return HashOf(p, cdouble.sizeof);
    }
    
    override bool Equals(in void* p1, in void* p2) {
        return _equals(*cast(cdouble *)p1, *cast(cdouble *)p2);
    }
    
    override int Compare(in void* p1, in void* p2) {
        return _compare(*cast(cdouble *)p1, *cast(cdouble *)p2);
    }
    
    override @property size_t TSize() nothrow pure {
        return cdouble.sizeof;
    }
    
    override void Swap(void *p1, void *p2) {
        cdouble t;
        
        t = *cast(cdouble *)p1;
        *cast(cdouble *)p1 = *cast(cdouble *)p2;
        *cast(cdouble *)p2 = t;
    }
    
    override const(void)[] Init() nothrow pure {
        static immutable cdouble r;
        
        return (cast(cdouble *)&r)[0 .. 1];
    }
    
    override @property size_t TAlign() nothrow pure {
        return cdouble.alignof;
    }
    
    override int ArgTypes(out TypeInfo arg1, out TypeInfo arg2) {
        arg1 = typeid(double);
        arg2 = typeid(double);
        return 0;
    }
}
