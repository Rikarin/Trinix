module Modules.Input.PS2KeyboardMouse.Main;

import Core;
import ObjectManager;
import Modules.Input.PS2KeyboardMouse.KBC8042;
import Modules.Input.PS2KeyboardMouse.PS2Mouse;


public static class PS2KeyboardMouse { //TODO: IStaticModule
	public static ModuleResult Initialize(string[] args) {
		KBC8042.Initialize();
		PS2Mouse.EnableMouse = &KBC8042.EnableMouse;

		Log.WriteLine("PS2KeyboardMouse module was initialized");
		return ModuleResult.Sucessful;
	}
}