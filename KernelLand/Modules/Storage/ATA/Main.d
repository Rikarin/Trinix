module Modules.Storage.ATA.Main;

import Core;
import ObjectManager;
import Modules.Storage.ATA.ATAController;


public class ATA { //TODO: IStaticModule
	private static __gshared ATAController[2] _controllers;

	public static ModuleResult Initialize(string[] args) {
		_controllers = ATAController.Detect();

		Log.WriteLine("ATA module was initialized");
		return ModuleResult.Sucessful;
	}

	public static ModuleResult Finalize() {
		delete _controllers[0];
		delete _controllers[1];

		Log.WriteLine("ATA module was finalized");
		return ModuleResult.Error;
	}
}