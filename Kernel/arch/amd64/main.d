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
import kernel_main;


extern(C) void main(uint magic, void* info) @safe nothrow {
	GDT.init();
	IDT.init();
	PIT.init();
	// syscallhandler TODO
	
	kernel_main();
}
