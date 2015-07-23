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

module Architecture.Main;

import Core;
import VFSManager;
import Architecture;
import ObjectManager;
import MemoryManager;


extern(C) void ArchMain(uint magic, v_addr info) {
    Logger.Initialize();

    Log("multiboot2");
    Multiboot.ParseHeader(magic, info);

    CPU.Initialize();

    Log("Jumping to [KernelMain]");
    KernelMain();
}

void LoadModules() {
    new DirectoryNode(DeviceManager.DevFS, FSNode.NewAttributes("BootModules"));

    foreach (tmp; Multiboot.Modules[0 .. Multiboot.ModulesCount]) {
        char* str    = &tmp.String;
        ulong addr   = tmp.ModStart | LinkerScript.KernelBase;
        ulong length = tmp.ModEnd - tmp.ModStart;

        Log("Start: %16x, Length: %16x, CMD: %s", addr, length, cast(string)str[0 .. tmp.Size - 17]);

        if (!ModuleManager.LoadMemory((cast(byte *)addr)[0 .. length], cast(string)str[0 .. tmp.Size - 17]))
            Log("Module: Unable to load module located at %x", addr);
        else
            Log("Module: module was successfuly loaded");


        /*  auto elf = Elf.Load(cast(void *)(cast(ulong)LinkerScript.KernelBase | cast(ulong)tmp.ModStart), "/System/Modules/lol.html");
        if (elf)
            elf.Relocate(null);*/
    }
}