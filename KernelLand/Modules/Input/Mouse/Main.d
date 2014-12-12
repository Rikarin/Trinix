module Modules.Input.Mouse.Main;

import Core;
import VFSManager;
import ObjectManager;


static class Mouse { //TODO: IStaticModule
	static ModuleResult Initialize(string[] args) {
		DeviceManager.DevFS.Create(FSNode.NewAttributes("mouse"));
		Log.WriteLine("Mouse module was initialized");
		return ModuleResult.Sucessful;
	}

	static ModuleResult Finalize() {
		auto del = DeviceManager.DevFS["mouse"];
		delete del;

		Log.WriteLine("Keyboard module was finalized");
		return ModuleResult.Error;
	}
}