/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
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