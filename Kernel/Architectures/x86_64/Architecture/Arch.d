/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Architecture.Arch;

import Core;
import MemoryManager;


class Arch : IArch {
    IPaging InitialzePaging() {
        return null;
    }

    void InitializeTimer(int freqency) {
        PIT.Initialize(freqency);
    }
}

extern(C) void ArchMain(uint magic, void* info) {
	/* Initialize SSE for vararg used in Logger */
    //TODO: this is not needed now
	Port.InitializeSSE();
	Port.EnableSSE();

    Logger.Initialize();
    Log("Cau amigo!");

    Log("multiboot2");
    Multiboot.ParseHeader(magic, info);

    Log("Initialize CPU");
    CPU.Initialize();

    __gshared Arch arch;
    arch = Arch.init;

    Log("Jumping to [KernelMain]");
    KernelMain();
}
