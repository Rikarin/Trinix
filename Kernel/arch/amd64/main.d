/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module arch.amd64.main;

import arch.amd64.gdt;
import arch.amd64.idt;
import arch.amd64.pit;


extern(C) void main(uint magic, void* info) @safe nothrow {
	GDT.init();
	IDT.init();
	
	PIT.init();
	
	// TODO: now jump into higher kernel

	// everything after this should be moved into kernel main
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
