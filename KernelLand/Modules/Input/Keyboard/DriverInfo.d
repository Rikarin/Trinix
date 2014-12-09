module Modules.Input.Keyboard.DriverInfo;

import ObjectManager;
import Modules.Input.Keyboard.Main;


extern(C) __gshared ModuleDef _DriverInfo_Input_Keyboard = {
	Magic: ModuleMagic,
	Architecture: ModuleArch.x86_64,
	Flags: 0x00,
	Version: 0x01,
	Name: "Keyboard Input Module",
	Identifier: "com.trinix.Input.Keyboard",
	Initialize: &Keyboard.Initialize,
	Finalize: &Keyboard.Finalize
};