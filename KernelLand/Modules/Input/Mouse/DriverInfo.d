module Modules.Input.Mouse.DriverInfo;

import ObjectManager;
import Modules.Input.Mouse.Main;


extern(C) __gshared ModuleDef _DriverInfo_Input_Mouse = {
	Magic: ModuleMagic,
	Architecture: ModuleArch.x86_64,
	Flags: 0x00,
	Version: 0x01,
	Name: "Mouse Input Module",
	Identifier: "com.trinix.Input.Mouse",
	Initialize: &Mouse.Initialize,
	Finalize: &Mouse.Finalize
};