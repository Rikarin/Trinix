module Modules.Input.PS2KeyboardMouse.DriverInfo;

import ObjectManager;
import Modules.Input.PS2KeyboardMouse.Main;
import Modules.Input.PS2KeyboardMouse.PS2Mouse;
import Modules.Input.PS2KeyboardMouse.PS2Keyboard;


extern(C) __gshared ModuleDef _DriverInfo_Input_PS2KeyboardMouse = {
	Magic: ModuleMagic,
	Architecture: ModuleArch.x86_64,
	Flags: 0x00,
	Version: 0x01,
	Name: "PS2 Keyboard/Mouse Input Module",
	Identifier: "com.modules.Input.PS2KeyboardMouse",
	Initialize: &PS2KeyboardMouse.Initialize
};

extern(C) __gshared ModuleDef _DriverInfo_Input_PS2Keyboard = {
	Magic: ModuleMagic,
	Architecture: ModuleArch.x86_64,
	Flags: 0x00,
	Version: 0x01,
	Name: "PS2 Keyboard Input Module",
	Identifier: "com.modules.Input.PS2Keyboard",
	Initialize: &PS2Keyboard.Initialize,
	Dependencies: [
		{"com.modules.Input.PS2KeyboardMouse", []},
		{"com.modules.Input.Keyboard", []}
	]
};

extern(C) __gshared ModuleDef _DriverInfo_Input_PS2Mouse = {
	Magic: ModuleMagic,
	Architecture: ModuleArch.x86_64,
	Flags: 0x00,
	Version: 0x01,
	Name: "PS2 Mouse Input Module",
	Identifier: "com.modules.Input.PS2Mouse",
	Initialize: &PS2Mouse.Initialize,
	Dependencies: [
		{"com.modules.Input.PS2KeyboardMouse", []},
		{"com.modules.Input.Mouse", []}
	]
};