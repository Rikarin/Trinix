/**
 * Copyright (c) 2014-2015 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 1.0 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * https://github.com/Bloodmanovski/Trinix and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module System.Runtime.SafeHandle;

import System.Runtime;


abstract class SafeHandle {
    protected long m_handle;

    protected this(int handle) {
        m_handle = handle;
    }

    ~this() {
        Syscall(SyscallType.Close);
    }

    protected long Syscall(long id, long param1 = 0, long param2 = 0, long param3 = 0, long param4 = 0, long param5 = 0) {
        return DoSyscall(m_handle, id, param1, param2, param3, param4, param5);
    }

    protected static SafeHandle StaticSyscall(long id, long param1 = 0, long param2 = 0, long param3 = 0, long param4 = 0, long param5 = 0) {
        return DoSyscall(0xFFFFFFFF_FFFFFFFF, id, param1, param2, param3, param4, param5);
    }

    /**
     * Perform syscall
     *
     * TODO:
     *      o do this as a naked call without mov??
     */
    private static long DoSyscall(long resource, long id, long param1, long param2, long param3, long param4, long param5) {
        asm {
            mov R9, resource;
            mov R8, id;
            mov RDI, pram1;
            mov RSI, param2;
            mov RDX, param3;
            mov RBX, param4;
            mov RAX, param5;
            syscall;
            
            mov resource, RAX;
        }

        return resource;
    }

    protected class SafeMethodCall {
        private long m_id;

        this(string identifier) {
            m_id = Syscall(SyscallType.Translate, cast(long)identifier.ptr);

            if (m_id == SyscallReturn.Error)
            {} // TODO: throw an exception
        }

        long Call(long param1 = 0, long param2 = 0, long param3 = 0, long param4 = 0, long param5 = 0) {
            return Syscall(m_id, param0, param1, param2, param3, param4, param5);
        }
    }
}