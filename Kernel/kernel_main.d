/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module kernel_main;

import io.log;
import io.vga;
import memory.frame_allocator;
import process_manager.scheduler;


void kernelMain() @safe nothrow {
    Log.init();
	VGA.init();
	
	//Log.write("Trinix is starting up...");
    //Log("version: %d.%d.%d", 0, 1, cast(int)giBuildNumber); // TODO
	
	FrameAllocator.init();
	
	// multiboot2 mem tables
	// preallocate frames for mem tables
	// init paging
	// init heap
	// init tls
	// parse multiboot 2
	// ACPI
	// IOAPIC
	// LAPIC and calibration
	// multi cpu/thread
	Scheduler.init();
	// we are done! Run init.d
	

    //Log("multiboot2");
    //Multiboot.ParseHeader(magic, info);

	


    /**
     * TODO:
     *      o Handle memory block from multiboot2 header
     *      o Allocate correct size of BitArray
     *      o Check if memory mapped regions work properly
     * +     o Make interface for Paging and move Paging.d to the arch-specific folder
     */
    //Log("Physical Memory");
    //PhysicalMemory.Initialize();

    /**
     * TOOD:
     *      - Size(const void * ptr) - will return the size of allocateds memory in heap
     *      o Implement GC from druntime library
     *
     */
    //Log("Virtual Memory");
    //VirtualMemory.Initialize();
}

/*void RemapPIC() {
    Port.Write(0x20, 0x11);
    Port.Write(0xA0, 0x11);
    Port.Write(0x21, 0x20);
    Port.Write(0xA1, 0x28);
    Port.Write(0x21, 0x04);
    Port.Write(0xA1, 0x02);
    Port.Write(0x21, 0x01);
    Port.Write(0xA1, 0x01);
    Port.Write(0x21, 0x00);
    Port.Write(0xA1, 0x00);
}*/

extern(C) extern const int BuildNumber;
