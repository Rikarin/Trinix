module Core.Main;

import Core;
import VFSManager;
import TaskManager;
import Architecture;
import MemoryManager;
import SyscallManager;

//Log dorobit... problem je v tom ze ak si vymknem log v processe tak pocas interruptu ho nemozem pouzit...
//v PhysicalMEmory by to chcelo nahrat regiony z multibootu a potom podla nich vytvorit bitmapu
//vo FSNode.NewAttributes opravit UID, GID
//Syscally v FSNode a DirectoryNode

//LibraryLoader a ELF aprser mozu ist kludne potom aj do libky...
/*
dokoncit VFS.
Dokoncit write/create/remove - spravit Ext2 driver!!!!
Multitasking a synchronizacne prvky
eventy
syscally
a az teraz robit moduly....
Timery....
datetime neviem ci ma dobre asm

Ext2:
BlockNode, CharNode,

V IDT je nejaky problem s RAX registrom...
*/

/* MemoryMap:
	0xFFFFFFFFE0000000 - mapovane regiony
*/

extern(C) void KernelMain(uint magic, void* info) {
	Log.Initialize();
	Log.Install();

	Log.WriteJSON("{");
	Log.WriteJSON("name", "Trinix");
	Log.WriteJSON("version", "0.0.1 Beta");
	Log.Base = 10;
	Log.WriteJSON("build", BuildNumber);
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

	Log.WriteJSON("vfs_manager", "[");
	Log.WriteJSON("{");
	Log.WriteJSON("name", "VFS");
	Log.WriteJSON("type", "Initialize");
	Log.WriteJSON("value", VFS.Initialize());
	Log.WriteJSON("type", "Install");
	Log.WriteJSON("value", VFS.Install());
	Log.WriteJSON("}");
	Log.WriteJSON("]");

	Log.WriteJSON("task_manager", "[");
	Log.WriteJSON("{");
	Log.WriteJSON("name", "Task");
	Log.WriteJSON("type", "Initialize");
	Log.WriteJSON("value", Task.Initialize());
	Log.WriteJSON("}");
	Log.WriteJSON("]");



	//tu by asi mali byt drivery
	import Drivers.ATA;
	import Drivers.PIT;
	import Drivers.PIC;
	import FileSystem.Ext2;

	ATAController.Detect(); // for testing only
	Ext2Filesystem.Mount(new DirectoryNode(VFS.Root, FSNode.NewAttributes("ext2")), cast(Partition)VFS.Find("/System/Devices/hdb1"));

	PIC.Initialize();
	PIC.Install();
	
	PIT.Initialize();
	PIT.Install();

	Log.WriteJSON("}");
	VFS.PrintTree(VFS.Root);


	Thread thr = new Thread(Task.CurrentThread);
	thr.Start(&testfce, null);
	thr.AddActive();

	Task.CurrentThread.WaitEvents(ThreadEvent.DeadChild);


	//Log.WriteLine("Running.....", PIT.Uptime);

	while (true) {
		Log.WriteLine("Running.....", PIT.Uptime);
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

	Log.WriteLine("Bye");
}

void testfce() {
	for (int i = 0; i < 0x100; i++) {
		asm {
			"mov R8, 0x741";
			"mov R9, 0x789";
			"syscall" : : "a"(0x123), "b"(0x4562), "d"(0xABCD), "D"(0x852), "S"(0x963);
		}
	}
	//while (true) {}
	//dorobit Exit thready
}




/*auto dir2 = new DirectoryNode(VFS.Root, FSNode.NewAttributes("ext-2"));
	Ext2Filesystem.Mount(dir2, cast(Partition)VFS.Find("/System/Devices/hdb2"));

	auto file = VFS.Find("/ext-1/daka zlozka/daky plyn");

	byte[] data = new byte[file.Attributes.Length];
	ulong red = file.Read(0, data);

	Log.WriteLine(file.Attributes);
	Log.WriteLine(data[0 .. red]);*/


/*auto file = VFS.Find("/ext2/dokument");

	byte[256] buffer;
	ulong l = file.Read(0, buffer);

	Log.WriteLine(cast(string)buffer[0 .. l]);
	file.Write(0, cast(byte[])"cau amigo");*/