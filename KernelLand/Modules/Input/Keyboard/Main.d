module Modules.Input.Keyboard.Main;

import Core;
import ObjectManager;


public class Keyboard {
	public static ModuleResult Initialize(string[] args) {
		Log.WriteLine("Keyboard module was initialized");
		return ModuleResult.Sucessful;
	}
	
	public static ModuleResult Finalize() {
		Log.WriteLine("Keyboard module was finalized");
		return ModuleResult.Error;
	}
}