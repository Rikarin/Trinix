/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Core.IArch;

import MemoryManager;


interface IArch {
    IPaging InitialzePaging();
    void InitializeTimer(int frequency);
}
