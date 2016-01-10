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

module Modules.Display.BochsGA.Main;

import Core;
import Architecture;
import ObjectManager;
import MemoryManager;


class BochsGA {
    enum BochsDispi {
        IndexID,
        IndexXRes,
        IndexYRes,
        IndexBpp,
        IndexEnable,
        IndexBank,
        IndexVirtWidth,
        IndexVirtHeight,
        IndexXOffset,
        IndexYOffset,

        BankAddress        = 0xA0000,
        LFBPhysicalAddress = 0xE0000000,
        IOPortIndex        = 0x01CE,
        IOPortData         = 0x01CF,
        Disabled           = 0x00,
        Enabled            = 0x01,
        LFBEnabled         = 0x40,
        NoClearMemory      = 0x80

    }

    static ModuleResult Initialize(string[] args) {
		Log("test 42  pica: %x", ReadRegister(BochsDispi.IndexID));

        VirtualMemory.MapRegion(cast(p_addr)(BochsDispi.LFBPhysicalAddress), 1);

        //mem[0] = 0;

     //   Log("len: %x", mem.length);


        /*foreach (ref x; mem) {
            x = 0;
        }*/

        return ModuleResult.Successful;
    }

    static ModuleResult Finalize() {
        
        return ModuleResult.Successful;
    }


    static void WriteRegister(ushort register, ushort value) {
        Port.Write!ushort(BochsDispi.IOPortIndex, register);
        Port.Write!ushort(BochsDispi.IOPortData, value);
    }

    static ushort ReadRegister(ushort register) {
        Port.Write!ushort(BochsDispi.IOPortIndex, register);
        return Port.Read!ushort(BochsDispi.IOPortData);
    }
}