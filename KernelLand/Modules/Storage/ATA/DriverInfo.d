module Modules.Storage.ATA.DriverInfo;

import ObjectManager;
import Modules.Storage.ATA.Main;


extern(C) const ModuleDef _DriverInfo_Storage_ATA = {
	Magic: ModuleMagic,
	Type: DeviceType.Input,
	Architecture: ModuleArch.x86_64,
	Flags: 0x00,
	Version: 0x01,
	Name: "ATA Storage Module",
	Identifier: "com.modules.Storage.ATA",
	Initialize: &ATA.Initialize,
	Finalize: &ATA.Finalize
};