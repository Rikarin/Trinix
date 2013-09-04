module Core.Main;

import Core.Log;
import MemoryManager.Memory;
import MemoryManager.PageAllocator;
import MemoryManager.PhysMem;
import MemoryManager.Heap;

import Architectures.Multiprocessor;
import Architectures.Paging;
import Architectures.Main;
import Architectures.CPU;

import DeviceManager.Device;
import DeviceManager.Display;

import VTManager.VT;

import SyscallManager.Res;

import Devices.Timer;
import Devices.Keyboard.PS2Keyboard;
import Devices.Display.VGATextOutput;

/++
Framework:
	BitArray
	Mutex
	-Wchar atd.
	Color - FromKnownColor name, ToUpper...
	convert - prerobit na vlastny string bez alloc
	list - search a delete

System:
	MP
	VTManager
	dorobit IDT
	VirtualTerminal SC a doladit Read()

	Dorobit heap & delete!!
	Az potom VFS a syscall mgr
	dorobit string
	Panic - vypis Rx registrov, inak vsetko O.K.
	dorobit pipeDev, opravit, task switch
	dorobit Serialdev, inak vsetko funguje
	timer - wakeup and task switch
	pipedev task swich
++/

extern(C) void StartSystem() {
	Log.Init();
	//For debug print malloc and free
	//Memory.test = 123456789;
	Log.Print("Initializing Architecture: x86_64");
	Architecture.Init();

	Log.Print("Initializing Physical Memory & Paging");
	PhysMem.Init();

	Log.Print("Initializing CPU");
	CPU.Init();

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

	Log.Print("Initializing device manger");
	Log.Result(Device.Init());
	
//	Log.Print("Initializing keyboard manger");
	//Log.Result(Keyboard.Init());

	Log.Print("Initializing display manger");
	Log.Result(Display.Init());

	Log.Print("Initializing VT manager");
	Log.Result(VT.Init());
	
//==================== DEVICES ====================
	Log.Print("Initializing timer ticks = 100Hz");
	new Timer(100);
	Log.Result(true);

	Log.Print("Initializing PS/2 keyboard driver");
	new PS2Keyboard();
	Log.Result(true);

	Log.Print("Initializing VGA text output driver");
	VGATextOutput textOutput = new VGATextOutput();
	Log.Result(true);

	Log.Print("Init complete, starting terminal");
	Log.Result(false);


	//setup display mode
	//Display.SetMode(textOutput.GetModes()[0]);

	//import Devices.Mouse.PS2Mouse;
	//new PS2Mouse(); need to fix...


/*
Keyboard dm zmazat a kb pripojit do /dev
potom jednoducho sa nastavy fd k danemu proceu ktory bude symlinkovat na kb
odstranit vt manager a pridat tty

*/

	while (true) {}
}

	/*
	//VFS test
	import VFS.DirectoryNode;
	import FileSystem.SerialDev;
	import Devices.Port.SerialPort;

	auto root = new DirectoryNode("/", null);
	auto devs = new DirectoryNode("Devices", null);
	root.AddNode(devs);

	devs.AddNode(new SerialDev("ttyS0", new SerialPort(SerialPort.COM1)));
	devs.AddNode(new SerialDev("ttyS1", new SerialPort(SerialPort.COM2)));
	devs.AddNode(new SerialDev("ttyS2", new SerialPort(SerialPort.COM3)));
	devs.AddNode(new SerialDev("ttyS3", new SerialPort(SerialPort.COM4)));
	*/


	/* pipe test


*/