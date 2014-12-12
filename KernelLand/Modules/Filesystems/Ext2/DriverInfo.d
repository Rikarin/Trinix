module Modules.Filesystems.Ext2.DriverInfo;

import ObjectManager;
import Modules.Filesystems.Ext2.Main;


extern(C) __gshared ModuleDef _DriverInfo_Filesystems_Ext2 = {
	Magic: ModuleMagic,
	Architecture: ModuleArch.x86_64,
	Flags: 0x00,
	Version: 0x01,
	Name: "Ext2 Filesystem Module",
	Identifier: "com.modules.Filesystems.Ext2",
	Initialize: &Ext2.Initialize,
	Finalize: &Ext2.Finalize
};