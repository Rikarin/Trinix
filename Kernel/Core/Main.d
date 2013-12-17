module Core.Main;

import Core;
import FileSystem;
import VFSManager;
import TaskManager;
import MemoryManager;
import Architectures;
import SyscallManager;

import Drivers.Bus.PCI;


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
	//ATAController.Detect();
	Log.Result(true);

	Log.Print("Initializing PS/2 keyboard driver");
	//new PS2Keyboard();
	Log.Result(true);

	Log.Print("Initializing PS/2 mouse driver");
	//new PS2Mouse();
	Log.Result(true);

	Log.Print("Setuping BGA driver 800x600");
	//BGA.Init(800, 600);
	Log.Result(true);

	Log.Print("Finding PCI devices");
	PCIDev.ScanDevices();
	Log.Result(true);

	Log.Print("Initializing timer ticks = 100Hz");
	//new Timer(100);
	Log.Result(true);

	Log.Print("Booting complete, starting init process");
	Log.Result(false);





















	//auto ext = VFS.CreateDirectory("ext");
	//auto xx = Ext2.Mount(ext, cast(Partition)VFS.Find("/dev/hda1"));

	//auto test = new Ext2FileNode(xx, FSNode.NewAttributes("aaa"));
	//test.inode = 3;
	//auto data = new byte[256];
	//xx.Read(test, 0, data);

	//VFS.PrintTree(VFS.RootNode);


	/*auto aa = VFS.Find("/dev/hda1");
	if(aa) {
		byte[1000] xx;
		aa.Read(0, xx);
		Log.PrintSP(cast(string)xx);
	}*/

	//static import Userspace.GUI.Compositor;
	//Process.CreateProcess(cast(void function())&Userspace.GUI.Compositor.construct, ["/System/Bin/Compositor", "--single", "--nothing"]);
	while (true) {}
}

extern(C) void apEntry() {
	while (true) { }
}