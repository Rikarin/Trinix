module Modules.Input.Keyboard.Main;

import Core;
import ObjectManager;


class Keyboard {
	static ModuleResult Initialize(string[] args) {
		Log.WriteLine("Keyboard module was initialized");
		return ModuleResult.Sucessful;
	}
	
	static ModuleResult Finalize() {
		Log.WriteLine("Keyboard module was finalized");
		return ModuleResult.Error;
	}
}