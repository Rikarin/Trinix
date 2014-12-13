module Modules.Input.Mouse.Main;

import Core;
import VFSManager;
import ObjectManager;


static class Mouse {
	static ModuleResult Initialize(string[] args) {
		DeviceManager.DevFS.Create(FSNode.NewAttributes("mouse"));

		return ModuleResult.Sucessful;
	}

	static ModuleResult Finalize() {
		auto del = DeviceManager.DevFS["mouse"];
		delete del;

		return ModuleResult.Error;
	}
}