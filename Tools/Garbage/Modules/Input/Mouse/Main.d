/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Modules.Input.Mouse.Main;

import ObjectManager;

import Modules.Input.Mouse;


static class Mouse : Resource {
    this(string identifier, int ver, int numButtons, int numAxis) {
        static const CallTable[] callTable = [

        ];

        super(DeviceType.Input, identifier, ver, callTable);
    }

    static void HandleEvent(int buttonState, int[] axisDeltas) {
        import Core;
        Log("mouse moved! buttons = %d, x = %d, y = %d", buttonState, axisDeltas[0], axisDeltas[1]);
    }
}