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
module Runtime.TypeInfo.ti_double;

import Runtime.Utilities.Hash;


class TypeInfo_d : TypeInfo { /* double */
@trusted:
pure:
nothrow:
    package static bool _equals(double f1, double f2) {
        return f1 == f2;
    }
    
    package static int _compare(double d1, double d2) {
        if (d1 != d1 || d2 != d2) { // if either are NaN
            if (d1 != d1) {
                if (d2 != d2)
                    return 0;
                return -1;
            }
            return 1;
        }
        return (d1 == d2) ? 0 : ((d1 < d2) ? -1 : 1);
    }
    
const:
    override string ToString() const pure nothrow @safe {
        return "double";
    }
    
    override size_t GetHash(in void* p) {
        return HashOf(p, double.sizeof);
    }
    
    override bool Equals(in void* p1, in void* p2) {
        return _equals(*cast(double *)p1, *cast(double *)p2);
    }
    
    override int Compare(in void* p1, in void* p2) {
        return _compare(*cast(double *)p1, *cast(double *)p2);
    }
    
    override @property size_t TSize() nothrow pure {
        return double.sizeof;
    }
    
    override void Swap(void *p1, void *p2) {
        double t;
        
        t = *cast(double *)p1;
        *cast(double *)p1 = *cast(double *)p2;
        *cast(double *)p2 = t;
    }
    
    override const(void)[] Init() nothrow pure {
        static immutable double r;
        
        return (cast(double *)&r)[0 .. 1];
    }
    
    override @property size_t TAlign() nothrow pure {
        return double.alignof;
    }

    override @property uint Flags() nothrow pure const @safe {
        return 2;
    }
}