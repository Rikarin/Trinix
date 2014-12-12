module Modules.Storage.ATA.Main;

import Core;
import ObjectManager;
import Modules.Storage.ATA.ATAController;


class ATA { //TODO: IStaticModule
	private __gshared ATAController[2] _controllers;

	static ModuleResult Initialize(string[] args) {
		_controllers = ATAController.Detect();

		Log.WriteLine("ATA module was initialized");
		return ModuleResult.Sucessful;
	}

	static ModuleResult Finalize() {
		delete _controllers[0];
		delete _controllers[1];

		Log.WriteLine("ATA module was finalized");
		return ModuleResult.Error;
	}
}