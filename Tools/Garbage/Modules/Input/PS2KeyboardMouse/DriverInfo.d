/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Modules.Input.PS2KeyboardMouse.DriverInfo;

import ObjectManager;
import Modules.Input.PS2KeyboardMouse.Main;
import Modules.Input.PS2KeyboardMouse.PS2Mouse;
import Modules.Input.PS2KeyboardMouse.PS2Keyboard;


extern(C) const ModuleDef _DriverInfo_Input_PS2KeyboardMouse = {
    Magic: MODULE_MAGIC,
    Type: DeviceType.Input,
    Architecture: ModuleArch.x86_64,
    Flags: 0x00,
    Version: 0x01,
    Name: "PS2 Input Module",
    Identifier: "com.modules.Input.PS2KeyboardMouse",
    Initialize: &PS2KeyboardMouse.Initialize
};

extern(C) const ModuleDef _DriverInfo_Input_PS2Keyboard = {
    Magic: MODULE_MAGIC,
    Type: DeviceType.Input,
    Architecture: ModuleArch.x86_64,
    Flags: 0x00,
    Version: 0x01,
    Name: "PS2 Keyboard Input Module",
    Identifier: "com.modules.Input.PS2Keyboard",
    Initialize: &PS2Keyboard.Initialize,
    Finalize: &PS2Keyboard.Finalize,
    Dependencies: [
        {"com.modules.Input.PS2KeyboardMouse", []},
        {"com.modules.Input.Keyboard", []}
    ]
};

extern(C) const ModuleDef _DriverInfo_Input_PS2Mouse = {
    Magic: MODULE_MAGIC,
    Type: DeviceType.Input,
    Architecture: ModuleArch.x86_64,
    Flags: 0x00,
    Version: 0x01,
    Name: "PS2 Mouse Input Module",
    Identifier: "com.modules.Input.PS2Mouse",
    Initialize: &PS2Mouse.Initialize,
    Finalize: &PS2Mouse.Finalize,
    Dependencies: [
        {"com.modules.Input.PS2KeyboardMouse", []},
        {"com.modules.Input.Mouse", []}
    ]
};