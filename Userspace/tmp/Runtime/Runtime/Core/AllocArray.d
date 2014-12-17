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
module Runtime.Core.AllocArray;


extern (C) void* __alloca(int nbytes) {
    asm {
        naked                   ;
        mov     RDX,RCX         ;
        mov     RAX,RDI         ; // get nbytes
        add     RAX,15          ;
        and     AL,0xF0         ; // round up to 16 byte boundary
        test    RAX,RAX         ;
        jnz     Abegin          ;
        mov     RAX,16          ; // allow zero bytes allocation
    Abegin:
        mov     RSI,RAX         ; // RSI = nbytes
        neg     RAX             ;
        add     RAX,RSP         ; // RAX is now what the new RSP will be.
        jae     Aoverflow       ;

        // Copy down to [RSP] the temps on the stack.
        // The number of temps is (RBP - RSP - locals).
        mov     RCX,RBP         ;
        sub     RCX,RSP         ;
        sub     RCX,[RDX]       ; // RCX = number of temps (bytes) to move.
        add     [RDX],RSI       ; // adjust locals by nbytes for next call to alloca()
        mov     RSP,RAX         ; // Set up new stack pointer.
        add     RAX,RCX         ; // Return value = RSP + temps.
        mov     RDI,RSP         ; // Destination of copy of temps.
        add     RSI,RSP         ; // Source of copy.
        shr     RCX,3           ; // RCX to count of qwords in temps
        rep                     ;
        movsq                   ;
        jmp     done            ;
        
    Aoverflow:
        // Overflowed the stack.  Return null
        xor     RAX,RAX         ;
        
    done:
        ret                     ;
    }
}