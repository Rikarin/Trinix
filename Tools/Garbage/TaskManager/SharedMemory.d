/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module TaskManager.SharedMemory;

import ObjectManager;


class SharedMemory : Resource {
    private enum IDENTIFIER = "com.trinix.TaskManager.SharedMemory";


    this() {
        CallTable[] callTable = [

        ];

        super(DeviceType.IPC, IDENTIFIER, 0x01, callTable);
    }
}