module Modules.Terminal.VTY.DriverInfo;

import ObjectManager;
import Modules.Terminal.VTY.Main;


extern(C) const ModuleDef _DriverInfo_Terminal_VTY = {
	Magic: ModuleMagic,
	Type: DeviceType.Terminal,
	Architecture: ModuleArch.x86_64,
	Flags: 0x00,
	Version: 0x01,
	Name: "VTY Terminal Module",
	Identifier: "com.modules.Terminal.VTY",
	Initialize: &VTY.Initialize,
	Finalize: &VTY.Finalize
};