/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Modules.Storage.ATA.Main;

import Core;
import ObjectManager;
import Modules.Storage.ATA.ATAController;


class ATA {
    private __gshared ATAController[2] m_controllers;

    static ModuleResult Initialize(string[] args) {
        m_controllers = ATAController.Detect();

        return ModuleResult.Successful;
    }

    static ModuleResult Finalize() {
        delete m_controllers[0];
        delete m_controllers[1];

        return ModuleResult.Successful;
    }
}