/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * TODO:
 *      o Make binutils patch for version 2.25
 *      o parse command line
 *      o Dynamic module loader
 *      o ELF parser, binary loader
 *      o GUI compositor (daemon)
 *      o Compile Kappa framework and link it with Kernel (we needs support for SDL now)
 *      o Move things from Library to Kappa framework
 *      o Rewrite modules as a deamons/services
 *      o Implement Message passing (IPC), resource manager, dispatch, message manager, io manager
 *      o make resource manager (procd) managing thread
 *
 *      Node ID/Procces ID/Channel ID
 *
 *      o Whole concept of the kernel should be moved from monolitic syscalls to sync message passing
 *      o Rewrite MemoryManager/Heap.d, move it to the framework and replace heap from druntime, then we can use GC
 *
 *
 * DRIVERS:
 *      o Keyboard
 *      o Mouse
 *      o PCI
 *      o Pipes
 *      o Serial/Parallel
 *      o VTY/TTY
 *      o VGA driver (needs PCI)
 *      o Sound Driver
 *      o Network drivers
 *      o EHCI UHCI XHCI - USB
 *
 * Kernel Parts:
 *      o Memory Manager
 *      o Task manager (IPC)
 *
 * Resource Managers:
 *      o VFS
 *      o Network - TCP stack, etc.
 *      o procd
 *      o device deamon
 *
 * IPC:
 *      o Shared Memory - deprecated, but usable
 *      o Mutex, Semaphore, RWLock (implement in userspace), SpinLock (userspace implementation)
 *      o Event - something like pthread_cond_lock ??
 *      o synchronous and asynchronous message passing, like in QNX
 *      o Maybe: sysenter/sysexit should be avoided. We will make procd for handling messages
 *               Better fault protection - just run watchdog as a new thread and look for freezing daemons, then restart it
 *
 * Library classes:
 *      o Message { this(int channelID); long Send(byte[] buffer); int Receive(byte[] buffer); void Reply(byte[] buffer); void Error(int errorCode); static Message Attach(int channelID); }
 *      o ResourceManager
 *      o IO Manager - Connect: open, rename | IO: write, read, seek
 *      o Message Manager
 *      o Dispatch
 */

module kernel_main;

import Core;
import Library;
import Architecture;
import MemoryManager;

//==============================================================================
/* MemoryMap:
    0xFFFFFFFFE0000000 - 0xFFFFFFFFF0000000 - mapped regions
*/
extern(C) extern const int giBuildNumber;
extern(C) extern const char* gsGitHash;
extern(C) extern const char* gsBuildInfo;

void kernelMain() {
    Logger.Initialize();
	// VGA init
	// Frame allocator (phys mem)
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
	// scheduler init
	// we are done! Run init.d

    Log("multiboot2");
    Multiboot.ParseHeader(magic, info);
	
	
    Log("Git Hash: %s", gsGitHash.ToString());
    Log("Version: %d", cast(int)giBuildNumber);
    Log("Build Info: %s", gsBuildInfo.ToString());

    /**
     * TODO:
     *      o Handle memory block from multiboot2 header
     *      o Allocate correct size of BitArray
     *      o Check if memory mapped regions work properly
     * +     o Make interface for Paging and move Paging.d to the arch-specific folder
     */
    Log("Physical Memory");
    PhysicalMemory.Initialize();

    /**
     * TOOD:
     *      - Size(const void * ptr) - will return the size of allocateds memory in heap
     *      o Implement GC from druntime library
     *
     */
    Log("Virtual Memory");
    VirtualMemory.Initialize();

    Log("Syscall Handler");
    SyscallHandler.Initialize();

    // Rework...
    Log("Task Manager");
    Task.Initialize();

    Log("Remaping PIC");
    RemapPIC();

    Log("RTC Timer");
    Time.Initialize();


 //   Log("spustam prvy proces");
    /* Copy current process into new one */
  //  auto p = new Process(&test_lala);
  //  p.Start();

    /* Copy curent thread into new one under the same process */
    Log("spustam prvu threadu");
    auto t = new Thread(&test_lala);
    t.Start();
    Log("prva threada bola spustena");

    Log("Running, Time = %d", Time.Uptime);
    while (true) {
        //Log("Running, Time = %d", Time.Uptime);
    }
}

void RemapPIC() {
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
}

void test_lala() {
   // Log("The new thread %d", Thread.Current.ID);
    //Log("The new process %d", Process.Current.ID);

    while (true) {
        asm {
        ll:
            jmp ll;
            //syscall;
        }
    }
}
