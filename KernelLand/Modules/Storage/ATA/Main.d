module Main; //Modules.Storage.ATA.Main;

import ObjectManager;


extern(C) __gshared static ModuleDef driverInfo = {
	Magic: ModuleMagic,
	Flags: 0,
	Version: 8,
	Name: "ATA modul testik",
	Initialize: &ATA.Initialize,
	Finalize: &ATA.Finalize,
	Dependencies: ["test", "niec ine"]
};


public class ATA {
	public static ModuleResult Initialize(string[] args) {
		import Core;
		Log.Write("test from ATA module");

		return ModuleResult.Sucessful;
	}

	public static ModuleResult Finalize() {
		return ModuleResult.Sucessful;
	}
}