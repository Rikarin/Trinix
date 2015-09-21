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

module ObjectManager.ModuleManager;

import Core;
import Linker;
import Library;
import VFSManager;
import Architecture;
import ObjectManager;


enum MODULE_MAGIC = 0xDEADC0DE;

enum ModuleResult {
    Error,
    Successful,

    Misc,
    BadModule
}

enum ModuleArch {
    Null,
    x86_64
}

enum ModuleFlags {
    Null,
    LoadError = 1
}

struct ModuleDependencies {
    string Name;
    string[] Args;
}

struct ModuleDef {
align(1):
    uint Magic;
    DeviceType Type;
    ModuleArch Architecture;
    ubyte Flags;
    ushort Version;
    string Name;
    string Identifier;
    
    ModuleResult function(string[] args) Initialize;
    ModuleResult function() Finalize;
    ModuleDependencies[] Dependencies;
}

abstract final class ModuleManager {
    private __gshared char m_number = '0'; /* TODO implement more than 10 modules... */
    private __gshared LinkedList!ModuleDef m_loadedModules;
    private __gshared LinkedList!ModuleDef m_loadingModules;
    private __gshared LinkedList!ModuleDef m_builtinModules;

    static void Initialize() {
        m_loadedModules  = new LinkedList!ModuleDef();
        m_loadingModules = new LinkedList!ModuleDef();
        m_builtinModules = new LinkedList!ModuleDef();
    }

    static void Finalize() {
        delete m_loadedModules;
        delete m_loadingModules;
        delete m_builtinModules;
    }

    static void LoadBuiltins() {
        Log("Loading modules...");

        for (ulong i = cast(ulong)LinkerScript.KernelModules; i < cast(ulong)LinkerScript.KernelModulesEnd;) {
            ModuleDef* mod = cast(ModuleDef *)i;
            
            if (mod.Magic == MODULE_MAGIC) {
                Log("Name: %s", mod.Name);
                Log(" - Identifier: %s", mod.Identifier);
                Log(" - Version: %d", mod.Version);
                Log(" - Flags: %d", mod.Flags);

                if (mod.Dependencies) {
                    Log(" - Dependencies: ");
                    foreach (x; mod.Dependencies)
                        Log("    - %s", x.Name);
                }

                m_builtinModules.Add(*mod);
                i += ModuleDef.sizeof;
            } else
                i++;
        }

        foreach (x; m_builtinModules)
            InitModule(x.Value, []);
    }

    static ModuleResult InitModule(ModuleDef mod, string[] args) {
        if (mod.Magic != MODULE_MAGIC) {
            Log("Error: Wrong module!");
            return ModuleResult.BadModule;
        }

        if (mod.Architecture != ModuleArch.x86_64) {
            Log("Error: Ths module isn't for this architecture");
            return ModuleResult.BadModule;
        }

        if (mod.Flags & ModuleFlags.LoadError) {
            Log("Error: Something went wrong");
            return ModuleResult.Misc;
        }

        if (m_loadedModules.Contains(mod))
            return ModuleResult.Successful;

        m_loadingModules.Add(mod);
        foreach (x; mod.Dependencies) {
            if (Array.Find(m_loadedModules, (LinkedListNode!ModuleDef o) => o.Value.Identifier == x.Name))
                continue;

            if (Array.Find(m_loadingModules, (LinkedListNode!ModuleDef o) => o.Value.Identifier == x.Name))
                continue;

            auto dep = Array.Find(m_builtinModules, (LinkedListNode!ModuleDef o) => o.Value.Identifier == x.Name);
            if (!dep) {
                Log("Error: Dependency mot found");
                return ModuleResult.Error;
            }

            InitModule(dep.Value, x.Args);
        }

        ModuleResult ret = mod.Initialize !is null ? mod.Initialize(args) : ModuleResult.Successful;
        m_loadingModules.Remove(mod);

        if (ret != ModuleResult.Successful) {
            switch (ret) {
                case ModuleResult.Misc:
                    Log("Error: something went wrong");
                    break;

                default:
                    Log("Error: unknown reason");
            }

            mod.Flags |= ModuleFlags.LoadError;
            return ret;
        }

        m_loadedModules.Add(mod);
        return ModuleResult.Successful;
    }

    static bool LoadMemory(byte[] buffer, string args) {
        MemoryNode node = new MemoryNode(buffer, VFS.Find!DirectoryNode("BootModules", DeviceManager.DevFS),
                                         FSNode.NewAttributes("mem" ~ m_number));
        m_number++;

        return LoadFile(node, args);
    }

    static bool LoadFile(FSNode file, string args) {
        BinaryLoader bin = BinaryLoader.LoadKernel(file);

        if (bin is null) {
            Log("ModuleManager: Loading %s module failed!", file.Location);
            return false;
        }

        bin.Relocate();
        return false;
    }
}