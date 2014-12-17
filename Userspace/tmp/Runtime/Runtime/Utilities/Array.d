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
module Runtime.Utilities.Array;

import Runtime.Utilities.String;


@safe nothrow:
void enforceTypedArraysConformable(T)(in char[] action, in T[] a1, in T[] a2, in bool allowOverlap = false) {
    _enforceSameLength(action, a1.length, a2.length);

    if(!allowOverlap)
        _enforceNoOverlap(action, a1.ptr, a2.ptr, T.sizeof * a1.length);
}

void enforceRawArraysConformable(in char[] action, in size_t elementSize, in void[] a1,
                                 in void[] a2, in bool allowOverlap = false) {
    _enforceSameLength(action, a1.length, a2.length);
    if(!allowOverlap)
        _enforceNoOverlap(action, a1.ptr, a2.ptr, elementSize * a1.length);
}

private void _enforceSameLength(in char[] action, in size_t length1, in size_t length2) {
    if(length1 == length2)
        return;
    
    SizeStringBuff tmpBuff = void;
    string msg = "Array lengths don't match for ";
    msg ~= action;
    msg ~= ": ";
    msg ~= length1.sizeToTempString(tmpBuff);
    msg ~= " != ";
    msg ~= length2.sizeToTempString(tmpBuff);
    throw new Error(msg);
}

private void _enforceNoOverlap(in char[] action, in void* ptr1, in void* ptr2, in size_t bytes) {
    const size_t d = ptr1 > ptr2 ? ptr1 - ptr2 : ptr2 - ptr1;
    if(d >= bytes)
        return;
    const overlappedBytes = bytes - d;
    
    SizeStringBuff tmpBuff = void;
    string msg = "Overlapping arrays in ";
    msg ~= action;
    msg ~= ": ";
    msg ~= overlappedBytes.sizeToTempString(tmpBuff);
    msg ~= " byte(s) overlap of ";
    msg ~= bytes.sizeToTempString(tmpBuff);
    throw new Error(msg);
}