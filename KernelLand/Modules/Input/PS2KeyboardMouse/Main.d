module Modules.Input.PS2KeyboardMouse.Main;

import ObjectManager;
import Modules.Input.PS2KeyboardMouse.KBC8042;
import Modules.Input.PS2KeyboardMouse.PS2Mouse;


static class PS2KeyboardMouse {
	static ModuleResult Initialize(string[] args) {
		KBC8042.Initialize();
		PS2Mouse.EnableMouse = &KBC8042.EnableMouse;

		return ModuleResult.Sucessful;
	}
}