/**
 * Copyright (c) 2014-2015 Trinix Foundation. All rights reserved.
 *
 * This file is part of Trinix Operating System and is released under Trinix
 * Public Source Licence Version 1.0 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 *
 * You may obtain a copy of the License at
 * https://github.com/Bloodmanovski/Trinix and read it before using this file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 *
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 *
 * TODO:
 *      o Make binutils patch for version 2.25
 *      o Add LLVM build and pathcer to the Externals/CrossCompiler
 *      o parse command line
 *      o Dynamic module loader
 *      o ELF parser, binary loader
 *      o GUI compositor (daemon)
 *      o Compile Kappa framework and link it with Kernel (we needs support for SDL now)
 *      o Move things from Library to Kappa framework
 *
 *      o Whole concept of the kernel should be moved from monolitic syscalls to sync message passing
 *      o Rewrite MemoryManager/Heap.d, move it to the framework and replace heap from druntime, then we can use GC
 *
 *
 * DRIVERS:
 *      o Keyboard
 *      o Mouse
 *      o PCI
 *      o PipeDev
 *      o Serial/Parallel
 *      o VTY
 *      o VGA driver (needs PCI)
 *
 * Kernel Parts:
 *      o Memory Manager
 *      o Task manager (IPC)
 *      o VFS - should be a daemon running in user space but "statically linked" with kernel ??
 *      o Network - Like VFS
 *
 * IPC:
 *      x Shared Memory - should be avoided
 *      o Mutex, Semaphore, RWLock (implement in userspace), SpinLock (userspace implementation)
 *      o Event - something like pthread_cond_lock ??
 *      o synchronous and asynchronous message passing, like in QNX
 *      o Maybe: sysenter/sysexit should be avoided. We can just make a kernel daemon for handling messages
 *               Better fault protection - just run watchdog as a new thread and look for freezing daemons, then restart it
 */

module Core.Main;

import Core;
import Linker;
import Library;
import VFSManager;
import TaskManager;
import Architecture;
import MemoryManager;
import ObjectManager;

//==============================================================================
/* MemoryMap:
    0xFFFFFFFFE0000000 - 0xFFFFFFFFF0000000 - mapped regions
*/
extern(C) extern const int giBuildNumber;
extern(C) extern const char* gsGitHash;
extern(C) extern const char* gsBuildInfo;

extern(C) void KernelMain() {
    Log("Git Hash: %s", gsGitHash.ToString());
    Log("Version: %d", cast(int)giBuildNumber);
    Log("Build Info: %s", gsBuildInfo.ToString());

    /**
     * TODO:
     *      o Handle memory block from multiboot2 header
     *      o Allocate correct size of BitArray
     *      o Check if memory mapped regionms work properly
     * +     o Make interface for Paging and move Paging.d to the arch-specific folder
     */
    Log("Physical Memory");
    PhysicalMemory.Initialize();

    /**
     * TOOD:
     *      o Size(const void * ptr) - will return the size of allocateds memory in heap
     *
     */
    Log("Virtual Memory");
    VirtualMemory.Initialize();


    // Destroy this crap. There will be syscalls only for message passing & other IPC
    Log("Resource Manager");
    ResourceManager.Initialize();

    Log("Syscall Handler");
    SyscallHandler.Initialize();

    // Rework...
    Log("Task Manager");
    Task.Initialize();

    // An another crap what will be removed from the kernel
    Log("VFS Manager");
    VFS.Initialize();

    Log("Remaping PIC");
    RemapPIC();

    Log("Initializing PIT");
    PIT.Initialize(100);

    Log("RTC Timer");
    Time.Initialize();

    // OMG go away
    Log("Binary Loader");
   // BinaryLoader.Initialize();

    Log("Module Manager");
    ModuleManager.Initialize();
    ModuleManager.LoadBuiltins();
    //LoadModules();

    // This should do /Binary/Init ran from ramdiskinit.img
    VFS.Mount(new DirectoryNode(VFS.Root, FileAttributes("ext2")),
              VFS.Find!Partition("/System/Devices/disk0s1"), "ext2");

   // debug VFS.PrintTree(VFS.Root);

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
