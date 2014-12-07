module Modules.Storage.ATA.Main;

import Core;
import ObjectManager;
import Modules.Storage.ATA.ATAController;


public class ATA {
	public static ModuleResult Initialize(string[] args) {
		ATAController.Detect();

		Log.WriteLine("ATA module was initialized");
		return ModuleResult.Sucessful;
	}

	public static ModuleResult Finalize() {
		Log.WriteLine("ATA module was finalized");
		return ModuleResult.Error;
	}
}