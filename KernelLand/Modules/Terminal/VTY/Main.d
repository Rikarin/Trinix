module Modules.Terminal.VTY.Main;

import ObjectManager;
import SyscallManager;
import Modules.Terminal.VTY.DriverInfo;


class VTY : Resource {


	this() {
		static const ResouceCallTable rcs = {_DriverInfo_Terminal_VTY.Identifier, &StaticCallback};
		static const CallTable[] callTable = [
			//{0, ".Attributes", 0, null}
		];
		
		ResourceManager.AddCallTables(rcs);
		super(_DriverInfo_Terminal_VTY, callTable);
	}

	static ModuleResult Initialize(string[] args) {
		return ModuleResult.Sucessful;
	}
	
	static ModuleResult Finalize() {
		return ModuleResult.Error;
	}


	static long StaticCallback(long param1, long param2, long param3, long param4, long param5) {
		return -2;
	}
}