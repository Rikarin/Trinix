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
import TaskManager.Task;
import SyscallManager.Res;
import SyscallManager.Syscall;

import Devices.Timer;
import Devices.Keyboard.PS2Keyboard;
import Devices.Display.VGATextOutput;

/+
Pipe dead
paging - kopirovanie stranok pri vytvoreni noveho procesu
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

	Log.Print("Initializing VFS manger");
	Log.Result(VFS.Init());

	Log.Print("Initializing multitasking");
	Log.Result(Task.Init());

//==================== DEVICES ====================
	Log.Print("Initializing timer ticks = 100Hz");
	new Timer(100);
	Log.Result(true);

	Log.Print("Initializing PS/2 keyboard driver");
	//new PS2Keyboard();
	Log.Result(true);

	Log.Print("Booting complete, starting init process");
	Log.Result(false);


	import System.Convert;
	import FileSystem.PipeDev;
	import VFSManager.PipeNode;
	import TaskManager.Thread;
	import TaskManager.Process;

	PipeDev pajpa = new PipeDev(0x1000, "pajpa");
	DeviceManager.DevFS.AddNode(pajpa);


	import TaskManager.Signal;
	Task.CurrentProcess.Signals[SigNum.SIGSEGV] = cast(void function())&pagefaultCallBack;

	//auto thr = new Thread(cast(void function())&testthr);
	//thr.Start();

	static import Userspace.Init;
	import Userspace.GUI.Terminal;
	Process.CreateProcess(cast(void function())&Userspace.Init.construct, ["/System/Bin/Init", "--single", "--nothing"]);
	//Process.CreateProcess(cast(void function())&Terminal.Main, ["test"]);

	//while (thr.ReturnValue != 0x456) {}
	//while (true) Log.Print("x");

	byte[] tmp = new byte[1];
	while (true) {
		pajpa.Read(0, tmp);
		Log.Print("" ~ tmp[0]);
		tmp[0] = 0;
	}

	while (true) {}
}

extern(C) void apEntry() {
	while (true) { }
}

extern(C) void pagefaultCallBack() {
	Log.Print("page fault");
	while (true) {}
	return;
}




/*
import System.IO.DirectoryInfo;

extern(C) void testthr() {
	auto di = new DirectoryInfo("/dev/pajpa");
	auto aa = new nicetry();

	//if (!di.Exists)
	//	di.Create();

	aa.write(0, cast(byte[])"Adresa pajpy je: ");
	aa.write(0, cast(byte[])di.FullName);

	//return 0x456;
}*/