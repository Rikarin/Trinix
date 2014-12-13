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
 *      o Log dorobit... problem je v tom ze ak si vymknem log v processe tak pocas interruptu ho nemozem pouzit...
 *      o v PhysicalMEmory by to chcelo nahrat regiony z multibootu a potom podla nich vytvorit bitmapu
 *      o dokoncit VFS., co tam este chyba?... file..., syscally, static cally, acl,...
 *      o Dokoncit write/create/remove - spravit Ext2 driver!!!!
 *      o Multitasking a synchronizacne prvky, asi rwlock ci jak
 *      o eventy, syscally
 *      o kontrolu parametrov pri syscalloch
 *      o ACLka do syscallov?
 *      o najprv skocit do arch zavislej casti kodu, tj. Arch/xxx/Main.d a az odtial potom preskocit sem...
 *      o debugovat Heap... Obcas to pada na expande...
 *      o spravit to iste jak je pre VFS.AddDriver ci co ale pre Node zariadenia.
 *      o Aby sa z modulu dali pridat veci ako je pipe, pty, vty, atd...
 *      o V IDT je nejaky problem s RAX registrom...
 *      o documentation, documentation, documentation, ...
 *      o Pridat licenciu a header do kazdeho sourcecode suboru...
 */

module Core.Main;

import Core;
import VFSManager;
import TaskManager;
import Architecture;
import MemoryManager;
import ObjectManager;
import SyscallManager;

//==============================================================================
/* MemoryMap:
	0xFFFFFFFFE0000000 - mapovane regiony

eXtensible Operating System
*/
extern(C) extern const int giBuildNumber;

extern(C) void KernelMain(uint magic, void* info) {
	Log.Initialize();
	Log.Install();

	Log.WriteJSON("{");
	Log.WriteJSON("name", "Trinix");
	Log.WriteJSON("version", "0.0.1 Beta");
	Log.Base = 10;
	Log.WriteJSON("build", cast(int)giBuildNumber);
	Log.Base = 16;

	Log.WriteJSON("architecture", "[");
	Arch.Main(magic, info);
	Log.WriteJSON("]");

	Log.WriteJSON("memory_manager", "[");
	Log.WriteJSON("{");
	Log.WriteJSON("name", "PhysicalMemory");
	Log.WriteJSON("type", "Initialize");
	Log.WriteJSON("value", PhysicalMemory.Initialize());
	Log.WriteJSON("}");

	Log.WriteJSON("{");
	Log.WriteJSON("name", "PhysicalMemory");
	Log.WriteJSON("type", "Install");
	Log.WriteJSON("value", PhysicalMemory.Install());
	Log.WriteJSON("}");

	Log.WriteJSON("{");
	Log.WriteJSON("name", "VirtualMemory");
	Log.WriteJSON("type", "Initialize");
	Log.WriteJSON("value", VirtualMemory.Initialize());
	Log.WriteJSON("}");

	Log.WriteJSON("{");
	Log.WriteJSON("name", "VirtualMemory");
	Log.WriteJSON("type", "Install");
	Log.WriteJSON("value", VirtualMemory.Install());
	Log.WriteJSON("}");
	Log.WriteJSON("]");

	Log.WriteJSON("syscall_manager", "[");
	Log.WriteJSON("{");
	Log.WriteJSON("name", "ResourceManager");
	Log.WriteJSON("type", "Initialize");
	Log.WriteJSON("value", ResourceManager.Initialize());
	Log.WriteJSON("}");

	Log.WriteJSON("{");
	Log.WriteJSON("name", "SyscallHandler");
	Log.WriteJSON("type", "Initialize");
	Log.WriteJSON("value", SyscallHandler.Initialize());
	Log.WriteJSON("}");
	Log.WriteJSON("]");

	Log.WriteJSON("task_manager", "[");
	Log.WriteJSON("{");
	Log.WriteJSON("name", "Task");
	Log.WriteJSON("type", "Initialize");
	Log.WriteJSON("value", Task.Initialize());
	Log.WriteJSON("}");
	Log.WriteJSON("]");

	Log.WriteJSON("vfs_manager", "[");
	Log.WriteJSON("{");
	Log.WriteJSON("name", "VFS");
	Log.WriteJSON("type", "Initialize");
	Log.WriteJSON("value", VFS.Initialize());
	Log.WriteJSON("type", "Install");
	Log.WriteJSON("value", VFS.Install());
	Log.WriteJSON("}");
	Log.WriteJSON("]");

	// Remap PIC...
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

	Time.Initialize();
	Time.Install();

	Log.WriteJSON("}");

	ModuleManager.Initialize();
	ModuleManager.LoadBuiltins();

	//mixin(import("../../../Makefile"));


	VFS.Mount(new DirectoryNode(VFS.Root, FSNode.NewAttributes("ext2")), 
	          cast(Partition)VFS.Find("/System/Devices/disk0s1"), "ext2");
	VFS.PrintTree(VFS.Root);

	Log.WriteLine("test: ", VFS.Root.Identifier);


	//Thread thr = new Thread(Task.CurrentThread);
	//thr.Start(&testfce, null);
	//thr.AddActive();

	//Task.CurrentThread.WaitEvents(ThreadEvent.DeadChild);


	Log.WriteLine("Running.....", Time.Uptime);

	while (true) {
		//Log.WriteLine("Running.....", Time.Uptime);
	}

/+	foreach (tmp; Multiboot.Modules[0 .. Multiboot.ModulesCount]) {
		char* str = &tmp.String;
		Log.WriteJSON("start", tmp.ModStart);
		Log.WriteJSON("end", tmp.ModEnd);
		Log.WriteJSON("cmd", cast(string)str[0 .. tmp.Size - 17]);

		import Library;
	/*	auto elf = Elf.Load(cast(void *)(cast(ulong)LinkerScript.KernelBase | cast(ulong)tmp.ModStart), "/System/Modules/kokot.html");
		if (elf)
			elf.Relocate(null);*/
	}+/

//	Log.WriteLine("Bye");
}

void testfce() {
	//for (int i = 0; i < 0x100; i++) {
	while (true) {
		/*asm {
			//"mov R8, 0x741";
			"mov R9, 2";
			"syscall";// : : "a"(123), "b"(0x4562), "d"(0xABCD), "D"(0x852), "S"(0x963);
		}*/
		//Handle.StaticCall(1);
		//Log.WriteLine("pica", Time.Now);
		//for (int j = 0; j < 0x100_000_00; j++) {}
	}

	//while (true) {}
	//dorobit Exit thready
}