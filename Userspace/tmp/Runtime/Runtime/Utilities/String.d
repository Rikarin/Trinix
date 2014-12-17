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
 * 
 * TODO:
 *      o Use methods from Kappa.framework
 */
module Runtime.Utilities.String;

import Runtime.Utilities.Memory;


@trusted:
pure:
nothrow:
alias UintStringBuff   = char[10];
alias UlongStringBuff  = char[20];
alias SizeStringBuff   = UlongStringBuff;
alias sizeToTempString = ulongToTempString;

char[] uintToTempString(size_t n)(in uint val, ref char[n] buff) {
    return val._unsignedToTempString(buff);
}

char[] ulongToTempString(size_t n)(in ulong val, ref char[n] buff) {
    return val._unsignedToTempString(buff);
}

private char[] _unsignedToTempString(T, size_t n)(in T val, ref char[n] buff) if(is(T == uint) || is(T == ulong)) {
    static assert(n >= (is(T == uint) ? 10 : 20), "Buffer is to small for `" ~ T.stringof ~ "`.");
    
    char* p = buff.ptr + buff.length;
    T k = val;
    do
        *--p = cast(char) (k % 10 + '0');
    while(k /= 10);
    
    return buff[p - buff.ptr .. $];
}

int dstrcmp(in char[] s1, in char[] s2) {
    int  ret = 0;
    auto len = s1.length;

    if( s2.length < len )
        len = s2.length;
    if( 0 != (ret = memcmp( s1.ptr, s2.ptr, len )) )
        return ret;

    return s1.length >  s2.length ? 1 :
    s1.length == s2.length ? 0 : -1;
}
