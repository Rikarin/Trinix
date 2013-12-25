module Core.Main;

import Core;
import FileSystem;
import VFSManager;
import TaskManager;
import MemoryManager;
import Architectures;
import SyscallManager;

import Drivers.Bus.PCI;
import Drivers.Disk.IDE;


/+
HEAP
PCI
AHCI
gpt

new:
HPET
acpi battery



IMPORTANT:
	Dokoncit EXT2
	ELF parser
	Linker
	paging - kopirovanie stranok pri vytvoreni noveho procesu
	need to fix install stack
	ATA Write() Treba prerobit tak ze ak zapisuje pod 256B tak si zvysok precita a prepise iba tie cisla ktore su v poly


NEJAKE NEPODSTATNE SRACKY:
	Pipe dead
	todo makefile
+/


extern(C) void StartSystem() {
	Log.Init();

	Log.Print("Initializing Architecture: x86_64");
	Architecture.Init();

	Log.Print("Initializing CPU");
	CPU.Init();

	Log.Print("Initializing Physical Memory & Paging");
	PhysMem.Init();

	Log.Print("Initializing kernel heap");

	//Memory.KernelHeap = new Heap(cast(ulong)PageAllocator.AllocPage(), Heap.MinSize, 0x10000, Paging.KernelPaging);
	//PageAllocator.IsInit = true;
	Log.Result(false);

	Log.Print("Initializing Multiprocessor configuration");
	Log.Result(Multiprocessor.Init());

	Log.Print("Starting multiple cores");
	Log.Result(true);
	Multiprocessor.BootCores();

//==================== MANAGERS ====================
	Log.Print("Initializing system calls database");
	Log.Result(Res.Init());

	Log.Print("Initializing syscall handler");
	Log.Result(Syscall.Init());

	Log.Print("Initializing device manger");
	Log.Result(DeviceManager.Init());

	Log.Print("Initializing VFS manger");
	Log.Result(VFS.Init());

	Log.Print("Initializing multitasking");
	Log.Result(Task.Init());

//==================== DEVICES ====================
	Log.Print("Detecting hard drives");
	ATAController.Detect();
	Log.Result(true);

	Log.Print("Initializing PS/2 keyboard driver");
	//new PS2Keyboard();
	Log.Result(false);

	Log.Print("Initializing PS/2 mouse driver");
	//new PS2Mouse();
	Log.Result(false);

	Log.Print("Setuping BGA driver 800x600");
	//BGA.Init(800, 600);
	Log.Result(false);

	Log.Print("Finding PCI devices");
	PCIDev.ScanDevices();
	Log.Result(true);

	Log.Print("Initializing timer ticks = 100Hz");
	//new Timer(100);
	Log.Result(false);

	Log.Print("Booting complete, starting init process");
	Log.Result(false);
	test();

	while (true) {}
}

extern(C) void apEntry() {
	while (true) { }
}





void test() {
	auto ext = VFS.CreateDirectory("ext");
	auto xx = Ext2.Mount(ext, cast(Partition)VFS.Find("/dev/hdb1"));

	auto test = new Ext2FileNode(xx, FSNode.NewAttributes("aaa"));
	test.inode = 4; //4
	auto data = new byte[2];

	VFS.PrintTree(VFS.RootNode);
	//xx.Read(test, 0, data);

	xx.readdir();





/*	auto aa = VFS.Find("/dev/hda1");
	if(aa) {
		byte[60] xx;
		aa.Read(0, xx);

		import System;
		foreach (x; xx)
			Log.PrintSP(" " ~ Convert.ToString(cast(ubyte)x, 16));
	}

	Log.PrintSP("\n\n\n\n");

	auto ff = VFS.Find("/dev/hda1");
	if(ff) {
		byte[60] xx;
		aa.Read(0, xx);

		import System;
		foreach (x; xx)
			Log.PrintSP(" " ~ Convert.ToString(cast(ubyte)x, 16));
	}*/


	//static import Userspace.GUI.Compositor;
	//Process.CreateProcess(cast(void function())&Userspace.GUI.Compositor.construct, ["/System/Bin/Compositor", "--single", "--nothing"]);
}