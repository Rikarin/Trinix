module ObjectManager.ModuleManager;

import Core;
import Library;
import VFSManager;
import Architecture;


enum ModuleMagic = 0xDEADC0DE;

enum ModuleResult {
	Error,
	Sucessful,

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
	private __gshared LinkedList!ModuleDef _loadedModules;
	private __gshared LinkedList!ModuleDef _loadingModules;
	private __gshared LinkedList!ModuleDef _builtinModules;

	static bool Initialize() {
		_loadedModules = new LinkedList!ModuleDef();
		_loadingModules = new LinkedList!ModuleDef();
		_builtinModules = new LinkedList!ModuleDef();

		return true;
	}

	static bool Finalize() {
		delete _loadedModules;
		delete _loadingModules;
		delete _builtinModules;

		return true;
	}

	static void LoadBuiltins() {
		Log.WriteJSON("modules", "[");

		for (ulong i = cast(ulong)LinkerScript.KernelModules; i < cast(ulong)LinkerScript.KernelModulesEnd;) {
			ModuleDef* mod = cast(ModuleDef *)i;
			
			if (mod.Magic == ModuleMagic) {
				Log.WriteJSON("{");
				Log.WriteJSON("name", mod.Name);
				Log.WriteJSON("identifier", mod.Identifier);
				Log.WriteJSON("version", mod.Version);
				Log.WriteJSON("flags", mod.Flags);

				if (mod.Dependencies) {
					Log.WriteJSON("dependencies", "[");
					foreach (x; mod.Dependencies)
						Log.WriteJSON(x.Name, x.Args);
					Log.WriteJSON("]");
				}
				Log.WriteJSON("}");

				_builtinModules.Add(*mod);
				i += ModuleDef.sizeof;
			} else
				i++;
		}
		Log.WriteJSON("]");

		foreach (x; _builtinModules)
			InitModule(x.Value, []);
	}

	static ModuleResult InitModule(ModuleDef mod, string[] args) {
		if (mod.Magic != ModuleMagic) {
			Log.WriteJSON("error", "Wrong module");
			return ModuleResult.BadModule;
		}

		if (mod.Architecture != ModuleArch.x86_64) {
			Log.WriteJSON("error", "Ths module isn't for this architecture");
			return ModuleResult.BadModule;
		}

		if (mod.Flags & ModuleFlags.LoadError) {
			Log.WriteJSON("error", "Somthing went wrong");
			return ModuleResult.Misc;
		}

		if (_loadedModules.Contains(mod))
			return ModuleResult.Sucessful;

		_loadingModules.Add(mod);
		foreach (x; mod.Dependencies) {
			if (Array.Find(_loadedModules, (LinkedListNode!ModuleDef o) => o.Value.Identifier == x.Name))
				continue;

			if (Array.Find(_loadingModules, (LinkedListNode!ModuleDef o) => o.Value.Identifier == x.Name))
				continue;

			auto dep = Array.Find(_builtinModules, (LinkedListNode!ModuleDef o) => o.Value.Identifier == x.Name);
			if (!dep) {
				Log.WriteJSON("error", "Dependency mot found");
				return ModuleResult.Error;
			}

			InitModule(dep.Value, x.Args);
		}

		ModuleResult ret = mod.Initialize(args);
		_loadingModules.Remove(mod);

		if (ret != ModuleResult.Sucessful) {
			switch (ret) {
				case ModuleResult.Misc:
					Log.WriteJSON("error", "something went wrong");
					break;

				default:
					Log.WriteJSON("error", "unknown reason");
			}

			mod.Flags |= ModuleFlags.LoadError;
			return ret;
		}

		_loadedModules.Add(mod);
		return ModuleResult.Sucessful;
	}

	/* This is garbage...
	static bool LoadMemory(void* buffer, long length, string args) {
		scope MemoryNode node = new MemoryNode(buffer, length, null, FSNode.NewAttributes("mem"));
		return LoadFile(node, args);
	}

	static bool LoadFile(FSNode file, string args) {
		return false;
	}*/
}