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
module Runtime.Utilities.Memory;


@trusted:
pure
nothrow:
extern(C) void* memcpy(void* dest, void* src, ulong count) {
    ubyte* d = cast(ubyte *)dest;
    ubyte* s = cast(ubyte *)src;
    
    for(size_t i = count; count; count--, d++, s++)
        *d = *s;

    return dest;
}

extern(C) int memcmp(const void *ptr1, const void *ptr2, ulong num) {
    int ret = 0;
    while (num--) {
        if ((cast(char *)ptr1)[num] != (cast(char *)ptr2)[num]) {
            ret = -1;
            break;
        }
    }

    return ret;
}

extern(C) void* memset(void* ptr, int value, ulong count) {
    ubyte *data = cast(ubyte*)ptr;
    for(int i = 0; i < count; i++)
        data[i] = cast(ubyte)value;
    
    return ptr;
}

extern(C) void* alloca(ulong); //TODO