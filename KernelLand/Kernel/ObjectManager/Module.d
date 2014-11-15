module ObjectManager.Module;

import VFSManager;


public enum ModuleMagic = 0xDEADC0DE;

public enum ModuleResult {
	Error,
	Sucessful
}

public struct ModuleDef {
align(1):
	uint Magic;
	ubyte Flags;
	ushort Version;
	string Name;
	
	ModuleResult function(string[] args) Initialize;
	ModuleResult function() Finalize;
	string[] Dependencies;
}

public abstract final class Module {
	public static bool LoadMemory(void* buffer, long length, string args) {
		scope MemoryNode node = new MemoryNode(buffer, length, null, FSNode.NewAttributes("mem"));
		return LoadFile(node, args);
	}

	public static bool LoadFile(FSNode file, string args) {
		return false;
	}
}