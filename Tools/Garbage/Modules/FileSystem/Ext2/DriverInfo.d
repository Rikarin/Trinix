/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Modules.FileSystem.Ext2.DriverInfo;

import ObjectManager;
import Modules.FileSystem.Ext2;


extern(C) const ModuleDef _DriverInfo_FileSystem_Ext2 = {
    Magic: MODULE_MAGIC,
    Type: DeviceType.FileSystem,
    Architecture: ModuleArch.x86_64,
    Flags: 0x00,
    Version: 0x01,
    Name: "Ext2 FileSystem Module",
    Identifier: "com.modules.FileSystem.Ext2",
    Initialize: &Ext2.Initialize,
    Finalize: &Ext2.Finalize
};