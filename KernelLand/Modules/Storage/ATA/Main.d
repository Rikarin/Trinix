module Modules.Storage.ATA.Main;

import Core;
import ObjectManager;
import Modules.Storage.ATA.ATAController;


public class ATA {
	public static ModuleResult Initialize(string[] args) {
		ATAController.Detect();

		Log.Write("ATA module was initialized");
		return ModuleResult.Sucessful;
	}

	public static ModuleResult Finalize() {

		Log.Write("ATA module was finalized");
		return ModuleResult.Error;
	}
}