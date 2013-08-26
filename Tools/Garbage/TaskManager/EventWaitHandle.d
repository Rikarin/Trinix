/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module TaskManager.EventWaitHandle;

import ObjectManager;


class EventWaitHandle : Resource {
    private enum IDENTIFIER = "com.trinix.TaskManager.EventWaitHandle";


    this() {
        CallTable[] callTable = [

        ];

        super(DeviceType.IPC, IDENTIFIER, 0x01, callTable);
    }
}