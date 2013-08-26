/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Modules.Input.Keyboard.Main;

import Core;
import Diagnostics;
import ObjectManager;

import Modules.Input.Keyboard;


class Keyboard : Resource {
    this(string identifier, long ver, int maxSym) {
        static const CallTable[] callTable = [
        
        ];

        super(DeviceType.Input, identifier, ver, callTable);
        Debugger.Log(LogLevel.Info, "Keyboard", "%s (version: %d) was registered", identifier, ver);
    }

    void HandleEvent(int hidCode) {
        Log("Hit %d", hidCode);
    }
}