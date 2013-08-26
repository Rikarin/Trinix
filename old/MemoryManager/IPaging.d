/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module MemoryManager.IPaging;

interface IPaging {
    /* Set paging table as current PT */
    void Install();

    /* Translate virtual address into physical */
    void* GetPhysicalAddress(const void* address);
}
