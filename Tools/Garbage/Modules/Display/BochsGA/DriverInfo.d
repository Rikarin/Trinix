/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Modules.Display.BochsGA.DriverInfo;

import ObjectManager;
import Modules.Display.BochsGA.Main;


extern(C) const ModuleDef _DriverInfo_Display_BochsGA = {
    Magic: MODULE_MAGIC,
    Type: DeviceType.Video,
    Architecture: ModuleArch.x86_64,
    Flags: 0x00,
    Version: 0x01,
    Name: "Bochs Graphic Adapter",
    Identifier: "com.modules.Display.BochsGA",
    Initialize: &BochsGA.Initialize,
    Finalize: &BochsGA.Finalize
};