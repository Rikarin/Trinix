module Modules.Input.Mouse.Main;

import Core;
import VFSManager;
import ObjectManager;


public static class Mouse { //TODO: IStaticModule
	public static ModuleResult Initialize(string[] args) {
		DeviceManager.DevFS.Create(FSNode.NewAttributes("mouse"));
		Log.WriteLine("Mouse module was initialized");
		return ModuleResult.Sucessful;
	}

	public static ModuleResult Finalize() {
		delete DeviceManager.DevFS["mouse"];

		Log.WriteLine("Keyboard module was finalized");
		return ModuleResult.Error;
	}
}