module Core.Main;

import Core.Log;
import Core.DeviceManager;

import MemoryManager.Heap;
import MemoryManager.Memory;
import MemoryManager.PhysMem;
import MemoryManager.PageAllocator;

import Architectures.CPU;
import Architectures.Main;
import Architectures.Paging;
import Architectures.Multiprocessor;

import VFSManager.VFS;
import VFSManager.Part;

import TaskManager.Task;
import TaskManager.Process;

import SyscallManager.Res;
import SyscallManager.Syscall;

import Devices.Timer;
import Devices.Display.BGA;
import Devices.Mouse.PS2Mouse;
import Devices.ATA.ATAController;
import Devices.Keyboard.PS2Keyboard;


/+
Pipe dead
paging - kopirovanie stranok pri vytvoreni noveho procesu
opravit read v ata drivru
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

	//Memory.KernelHeap = new Heap();
	//Memory.KernelHeap.Create(cast(ulong)PageAllocator.AllocPage(), Heap.MIN_SIZE, 0x10000, Paging.KernelPaging);
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

	Log.Print("Initializing partition manager");
	Log.Result(Part.Init());

	Log.Print("Initializing VFS manger");
	Log.Result(VFS.Init());

	Log.Print("Initializing multitasking");
	Log.Result(Task.Init());

//==================== DEVICES ====================
	Log.Print("Initializing timer ticks = 100Hz");
	new Timer(100);
	Log.Result(true);

	Log.Print("Detecting hard drives");
	ATAController.Detect();
	Log.Result(true);

	Log.Print("Initializing PS/2 keyboard driver");
	//new PS2Keyboard();
	Log.Result(true);

	Log.Print("Initializing PS/2 mouse driver");
	//new PS2Mouse();
	Log.Result(true);

	Log.Print("Setup BGA driver 800x600");
	//BGA.Init(800, 600);
	Log.Result(true);

	Log.Print("Booting complete, starting init process");
	Log.Result(false);

	//import Devices.PCI.PCIDev;
	//PCIDev.ScanDevices();

	//static import Userspace.GUI.Compositor;
	//Process.CreateProcess(cast(void function())&Userspace.GUI.Compositor.construct, ["/System/Bin/Compositor", "--single", "--nothing"]);

	while (true) {}
}

extern(C) void apEntry() {
	while (true) { }
}