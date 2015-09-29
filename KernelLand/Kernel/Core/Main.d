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
 *      o VFS
 *      o IPC: SharedMemory (like Mutex), RWLock, Syscalls
 *      o Syscall: ACL (for resources), params check (address, etc.)
 *      o parse command line
 *      o framework bundle automatic creator
 *      o Implement multi CPU support
 *      o Implementovat statementy ako @trusted nothrow @safe atd...
 *      o Exit thread - crt0 will call syscall(exit) at the end
 *      o Implement GC
 *      o Fix \n in Logger
 *      o Fix memory leak in FSNode by StringWriter
 *      o Make debugger soft in C#
 *      o FSDriver.Create() will format specific partition
 *      o Dynamic module loader
 *      o ELF parser, binary loader
 *      o GUI compositor
 *      o Library: StringBuilder(20%)
 *
 * DRIVERS:
 *      o Keyboard
 *      o Mouse
 *      o PCI
 *      o ACPI
 *      o AHCI
 *      o PipeDev
 *      o Serial/Parallel
 *      o VTY
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
import SyscallManager;

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

    Log("Physical Memory");
    PhysicalMemory.Initialize();

    Log("Virtual Memory");
    VirtualMemory.Initialize();

    Log("Resource Manager");
    ResourceManager.Initialize();

    Log("Syscall Handler");
    SyscallHandler.Initialize();

    Log("Task Manager");
    Task.Initialize();

    Log("VFS Manager");
    VFS.Initialize();

    Log("Remaping PIC");
    RemapPIC();

    Log("Initializing PIT");
    PIT.Initialize(100);

    Log("RTC Timer");
    Time.Initialize();

    Log("Binary Loader");
   // BinaryLoader.Initialize();

    Log("Module Manager");
    ModuleManager.Initialize();
    ModuleManager.LoadBuiltins();
    //LoadModules();

    VFS.Mount(new DirectoryNode(VFS.Root, FSNode.NewAttributes("ext2")), 
              VFS.Find!Partition("/System/Devices/disk0s1"), "ext2");

    //import Modules.Terminal.VTY.Main;
   // new VTY();

    debug VFS.PrintTree(VFS.Root);

 //   Log("spustam prvy proces");
    /* Copy current process into new one */
  //  auto p = new Process(&test_lala);
  //  p.Start();

    /* Copy curent thread into new one under the same process */
   // Log("spustam prvu threadu");
  //  auto t = new Thread(&test_lala);
  //  t.Start();
  //  Log("prva threada bola spustena");

    Log("Running, Time = %d", Time.Uptime);
    while (true) {
   //     Log("Running, Time = %d", Time.Uptime);
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
    Log("The new thread %d", Task.CurrentThread.ID);
    Log("The new process %d", Task.CurrentProcess.ID);

    while (true) {
        asm {
            //syscall;
        }
    }
}