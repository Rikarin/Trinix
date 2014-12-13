module Modules.Input.Mouse.DriverInfo;

import ObjectManager;
import Modules.Input.Mouse.Main;


extern(C) const ModuleDef _DriverInfo_Input_Mouse = {
	Magic: ModuleMagic,
	Type: DeviceType.Input,
	Architecture: ModuleArch.x86_64,
	Flags: 0x00,
	Version: 0x01,
	Name: "Mouse Input Module",
	Identifier: "com.modules.Input.Mouse",
	Initialize: &Mouse.Initialize,
	Finalize: &Mouse.Finalize
};