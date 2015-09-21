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

module Modules.Input.Keyboard.Main;

import Core;
import ObjectManager;
import SyscallManager;

import Modules.Input.Keyboard;


class Keyboard : Resource {
  /*  package static const ResouceCallTable m_rcs = {
        "com.modules.Input.Keyboard",
        &StaticCallback
    };
    For static calls.
    Need to by registered by ResourceManager.AddCallTable(FSNode.m_rcs);
    */


    protected this() {
        static const CallTable[] callTable = [
        
        ];

        super(_DriverInfo_Input_Keyboard, callTable);
    }

    ~this() { //remove instance

    }


    static ModuleResult Initialize(string[] args) {
        Log("TODO Keyboard init");
        return ModuleResult.Successful;
    }
    
    static ModuleResult Finalize() {
        Log("TODO Keyboard fin");
        return ModuleResult.Error;
    }

    static Keyboard CreateInstance(string identifier, int maxSym) {
        return new Keyboard();
    }

    void HandleEvent(int hidCode) {
        Log("Hit %d", hidCode);
    }

   /* static long StaticCallback(long param1, long param2, long param3, long param4, long param5) {
        return -1;
    }*/
}