/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
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
 *      o dokoncit VFS., co tam este chyba?... file..., syscally, static cally,
 *        acl,...
 *      o Dokoncit write/create/remove - spravit Ext2 driver!!!!
 *      o Multitasking a synchronizacne prvky, asi rwlock ci jak
 *      o eventy, syscally, shared memory
 *      o kontrolu parametrov pri syscalloch
 *      o ACLka do syscallov?
 *      o debugovat Heap... Obcas to pada na expande...
 *      o spravit to iste jak je pre VFS.AddDriver ci co ale pre Node zariadenia.
 *      o Aby sa z modulu dali pridat veci ako je pipe, pty, vty, atd...
 *      o documentation, documentation, documentation, ...
 *      o IMPORTANT: interfacovat syscally na konretne volania. tj. kazdy syscall
 *        moze mat uplne ine parametre
 *      o dokoncit keyboard a mouse driver.
 *      o spravit driver na PCI, pipedev, serial port...
 *      o parse command line
 *      o framework bundle automatic creator
 *      o Pridat nejaky protector ktory nedovoli allocovat ine bloky pamete okrem Free
 *      o opravit vsetky TODOcka
 *      o Implement multi CPU support
 *      o Implementovat statementy ako @trusted nothrow @safe atd...
 *      o prerobit gdc na bundle
 *      o Exit thready
 *      o Implement GC
 *      o Fix \n in Logger
 */

module Core.Main;

import Core;
import Linker;
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
   // Log("Git Hash: %s", cast(string)gsGitHash);
	Log("Version: %d", cast(int)giBuildNumber);
    //Log("Build Info: %s", cast(string)gsBuildInfo[0 .. 5]);

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
	Port.Write!byte(0x20, 0x11);
	Port.Write!byte(0xA0, 0x11);
	Port.Write!byte(0x21, 0x20);
	Port.Write!byte(0xA1, 0x28);
	Port.Write!byte(0x21, 0x04);
	Port.Write!byte(0xA1, 0x02);
	Port.Write!byte(0x21, 0x01);
	Port.Write!byte(0xA1, 0x01);
	Port.Write!byte(0x21, 0x00);
	Port.Write!byte(0xA1, 0x00);

    Log("Timer");
	Time.Initialize();

    Log("Binary Loader");
    BinaryLoader.Initialize();

    Log("Module Manager");
	ModuleManager.Initialize();
	ModuleManager.LoadBuiltins();
    LoadModules();

	VFS.Mount(new DirectoryNode(VFS.Root, FSNode.NewAttributes("ext2")), 
              VFS.Find!Partition("/System/Devices/disk0s1"), "ext2");


    import Modules.Terminal.VTY.Main;
   // new VTY();

   // debug VFS.PrintTree(VFS.Root);

	Log("Running, Time = %d", Time.Uptime);

	while (true) {
       // Log("Running, Time = %d", Time.Uptime);
	}
}