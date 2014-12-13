module Modules.Storage.ATA.Main;

import ObjectManager;
import Modules.Storage.ATA.ATAController;


class ATA {
	private __gshared ATAController[2] _controllers;

	static ModuleResult Initialize(string[] args) {
		_controllers = ATAController.Detect();

		return ModuleResult.Sucessful;
	}

	static ModuleResult Finalize() {
		delete _controllers[0];
		delete _controllers[1];

		return ModuleResult.Error;
	}
}