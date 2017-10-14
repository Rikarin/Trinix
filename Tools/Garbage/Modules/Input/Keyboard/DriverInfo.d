/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Modules.Input.Keyboard.DriverInfo;

import ObjectManager;
import Modules.Input.Keyboard;


extern(C) const ModuleDef _DriverInfo_Input_Keyboard = {
    Magic: MODULE_MAGIC,
    Type: DeviceType.Input,
    Architecture: ModuleArch.x86_64,
    Flags: 0x00,
    Version: 0x01,
    Name: "Keyboard Input Module",
    Identifier: "com.modules.Input.Keyboard"
};