module Modules.Storage.ATA.DriverInfo;

import ObjectManager;
import Modules.Storage.ATA.Main;


extern(C) __gshared ModuleDef _DriverInfo_Storage_ATA = {
	Magic: ModuleMagic,
	Architecture: ModuleArch.x86_64,
	Flags: 0x00,
	Version: 0x01,
	Name: "ATA Storage Module",
	Identifier: "com.trinix.Storage.ATA",
	Initialize: &ATA.Initialize,
	Finalize: &ATA.Finalize
};