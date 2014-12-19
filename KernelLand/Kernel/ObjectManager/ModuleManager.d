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
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module ObjectManager.ModuleManager;

import Core;
import Library;
import VFSManager;
import Architecture;
import ObjectManager;


enum ModuleMagic = 0xDEADC0DE;

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
    private __gshared char _number = '0';
	private __gshared LinkedList!ModuleDef _loadedModules;
	private __gshared LinkedList!ModuleDef _loadingModules;
	private __gshared LinkedList!ModuleDef _builtinModules;

	static void Initialize() {
		_loadedModules  = new LinkedList!ModuleDef();
		_loadingModules = new LinkedList!ModuleDef();
		_builtinModules = new LinkedList!ModuleDef();
	}

	static void Finalize() {
		delete _loadedModules;
		delete _loadingModules;
		delete _builtinModules;
	}

	static void LoadBuiltins() {
        Log("Loading modules...");

		for (ulong i = cast(ulong)LinkerScript.KernelModules; i < cast(ulong)LinkerScript.KernelModulesEnd;) {
			ModuleDef* mod = cast(ModuleDef *)i;
			
			if (mod.Magic == ModuleMagic) {
                Log("Name: %s, Identifier: %s", mod.Name, mod.Identifier);
                Log("Version: %d, Flags: %d", mod.Version, mod.Flags);

				if (mod.Dependencies) {
					Log("Dependencies: ");
					foreach (x; mod.Dependencies)
						Log(" - Name: %s", x.Name);
				}

				_builtinModules.Add(*mod);
				i += ModuleDef.sizeof;
			} else
				i++;
		}

		foreach (x; _builtinModules)
			InitModule(x.Value, []);
	}

	static ModuleResult InitModule(ModuleDef mod, string[] args) {
		if (mod.Magic != ModuleMagic) {
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

		if (_loadedModules.Contains(mod))
			return ModuleResult.Successful;

		_loadingModules.Add(mod);
		foreach (x; mod.Dependencies) {
			if (Array.Find(_loadedModules, (LinkedListNode!ModuleDef o) => o.Value.Identifier == x.Name))
				continue;

			if (Array.Find(_loadingModules, (LinkedListNode!ModuleDef o) => o.Value.Identifier == x.Name))
				continue;

			auto dep = Array.Find(_builtinModules, (LinkedListNode!ModuleDef o) => o.Value.Identifier == x.Name);
			if (!dep) {
				Log("Error: Dependency mot found");
				return ModuleResult.Error;
			}

			InitModule(dep.Value, x.Args);
		}

		ModuleResult ret = mod.Initialize(args);
		_loadingModules.Remove(mod);

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

		_loadedModules.Add(mod);
		return ModuleResult.Successful;
	}

    static bool LoadMemory(byte[] buffer, string args) {
        MemoryNode node = new MemoryNode(buffer, VFS.Find!DirectoryNode("MemoryModules", DeviceManager.DevFS),
                                         FSNode.NewAttributes("mem" ~ _number));
        _number++;

        return LoadFile(node, args);
    }

	static bool LoadFile(FSNode file, string args) {
		return false;
	}
}