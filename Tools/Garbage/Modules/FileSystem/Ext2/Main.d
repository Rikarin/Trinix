/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Modules.FileSystem.Ext2.Main;

import Core;
import VFSManager;
import ObjectManager;
import Modules.FileSystem.Ext2;


class Ext2 {
	private static const FSDriver info = {
        Name: "ext2",
        Detect: &Ext2FileSystem.Detect,
        Mount: &Ext2FileSystem.Mount,
        Create: &Ext2FileSystem.Create
	};

	static ModuleResult Initialize(string[] args) {	
		VFS.AddDriver(info);

		return ModuleResult.Successful;
	}

	static ModuleResult Finalize() {
		VFS.RemoveDriver("ext2");

		return ModuleResult.Successful;
	}
}