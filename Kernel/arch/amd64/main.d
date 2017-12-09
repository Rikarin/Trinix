/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module arch.amd64.main;

import arch.amd64.gdt;
import arch.amd64.idt;


extern(C) void main(uint magic, void* info) @safe nothrow {
	/* Initialize SSE for vararg used in Logger */
    //TODO: this is not needed now
	//Port.InitializeSSE();
//	Port.EnableSSE();

	GDT.init();
	IDT.init();

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
