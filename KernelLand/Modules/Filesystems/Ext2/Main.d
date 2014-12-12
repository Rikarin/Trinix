module Modules.Filesystems.Ext2.Main;

import Core;
import VFSManager;
import ObjectManager;

import Modules.Filesystems.Ext2.Ext2Filesystem;


class Ext2 { //TODO: IStaticModule
	private __gshared const FSDriver info = {
		Name: "ext2",
		Detect: &Ext2Filesystem.Detect,
		Mount: &Ext2Filesystem.Mount
	};

	static ModuleResult Initialize(string[] args) {		
		VFS.AddDriver(info);
		
		Log.WriteLine("Ext2 module was initialized");
		return ModuleResult.Sucessful;
	}

	static ModuleResult Finalize() {
		VFS.RemoveDriver("ext2");
		
		Log.WriteLine("Ext2 module was finalized");
		return ModuleResult.Error;
	}
}