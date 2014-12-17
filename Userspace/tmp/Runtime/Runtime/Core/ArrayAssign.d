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
module Runtime.Core.ArrayAssign;

import Runtime.Utilities.Array;
import Runtime.Utilities.Memory;


extern (C) void[] _d_arrayassign(TypeInfo ti, void[] from, void[] to) {
    auto element_size = ti.TSize;    
    enforceRawArraysConformable("copy", element_size, from, to, true);
    
    /* Need a temporary buffer tmp[] big enough to hold one element
     */
    void[16] buf = void;
    void[] tmp;

    if (element_size > buf.sizeof)
        tmp = alloca(element_size)[0 .. element_size];
    else
        tmp = buf[];
    
    
    if (to.ptr <= from.ptr) {
        foreach (i; 0 .. to.length) {
            void* pto   = to.ptr   + i * element_size;
            void* pfrom = from.ptr + i * element_size;

            memcpy(tmp.ptr, pto, element_size);
            memcpy(pto, pfrom, element_size);
            ti.Postblit(pto);
            ti.Destroy(tmp.ptr);
        }
    } else {
        for (auto i = to.length; i--;){
            void* pto   = to.ptr   + i * element_size;
            void* pfrom = from.ptr + i * element_size;

            memcpy(tmp.ptr, pto, element_size);
            memcpy(pto, pfrom, element_size);
            ti.Postblit(pto);
            ti.Destroy(tmp.ptr);
        }
    }
    return to;
}

/**
 * Does array initialization (not assignment) from another
 * array of the same element type.
 * ti is the element type.
 */
extern (C) void[] _d_arrayctor(TypeInfo ti, void[] from, void[] to) {
    auto element_size = ti.TSize;    
    enforceRawArraysConformable("initialization", element_size, from, to);
    
    size_t i;
    try {
        for (i = 0; i < to.length; i++) {
            // Copy construction is defined as bit copy followed by postblit.
            memcpy(to.ptr + i * element_size, from.ptr + i * element_size, element_size);
            ti.Postblit(to.ptr + i * element_size);
        }
    } catch (Throwable o) {
        /* Destroy, in reverse order, what we've constructed so far
         */
        while (i--)
            ti.Destroy(to.ptr + i * element_size);
        
        throw o;
    }
    return to;
}


/**
 * Do assignment to an array.
 *      p[0 .. count] = value;
 */
extern (C) void* _d_arraysetassign(void* p, void* value, int count, TypeInfo ti) {
    void* pstart = p;
    
    auto element_size = ti.TSize;
    
    //Need a temporary buffer tmp[] big enough to hold one element
    void[16] buf = void;
    void[] tmp;

    if (element_size > buf.sizeof)
        tmp = alloca(element_size)[0 .. element_size];
    else
        tmp = buf[];
    
    foreach (i; 0 .. count) {
        memcpy(tmp.ptr, p, element_size);
        memcpy(p, value, element_size);

        ti.Postblit(p);
        ti.Destroy(tmp.ptr);
        p += element_size;
    }
    return pstart;
}

/**
 * Do construction of an array.
 *      ti[count] p = value;
 */
extern (C) void* _d_arraysetctor(void* p, void* value, int count, TypeInfo ti) {
    void* pstart = p;
    auto element_size = ti.TSize;
    
    try {
        foreach (i; 0 .. count) {
            // Copy construction is defined as bit copy followed by postblit.
            memcpy(p, value, element_size);
            ti.Postblit(p);
            p += element_size;
        }
    } catch (Throwable o) {
        // Destroy, in reverse order, what we've constructed so far
        while (p > pstart) {
            p -= element_size;
            ti.Destroy(p);
        }
        
        throw o;
    }
    return pstart;
}