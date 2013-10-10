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

	PipeDev pajpa = new PipeDev(0x1000, "pajpa");
	DeviceManager.DevFS.AddNode(pajpa);
	
	(new Thread(cast(void function())&testthr)).Start();

	import TaskManager.Signal;
	SignalTable signal;
	signal.CallBack = cast(void function())&signalCallBack;
	Task.CurrentProcess.signalQueue.Add(signal);


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




import System.ResourceCaller;
import System.IFace;
import System.IO.DirectoryInfo;

extern(C) void testthr() {
	auto di = new DirectoryInfo("/dev/pajpa");
	auto aa = new nicetry();

	//if (!di.Exists)
	//	di.Create();

	aa.write(0, cast(byte[])"Adresa pajpy je: ");
	aa.write(0, cast(byte[])di.FullName);

	while (true) { }
}

extern(C) void signalCallBack() {
	ResourceCaller.StaticCall(0xABCD);
	while (true) {}
}




class nicetry : ResourceCaller {
	this() {
		super(12, 1);
	}

	void test() {
		Call(54);
	}

	ulong read(ulong offset, byte[] data) {
		return Call(2, [offset, cast(ulong)&data]);
	}

	ulong write(ulong offset, byte[] data) {
		return Call(3, [offset, cast(ulong)&data]);
	}
}



/* DEPRECATED:
	//Log.Print("Initializing VGA text output driver");
	//VGATextOutput textOutput = new VGATextOutput();
	//Log.Result(true);

	//setup display mode
	//Display.SetMode(textOutput.GetModes()[0]);

	//import Devices.Mouse.PS2Mouse;
	//new PS2Mouse(); need to fix...
*/


/*
	struct aast {
		int a;
		int b;
		int c;
	}

	aast struktura;
	struktura.a = 5;
	struktura.b = 10;
	struktura.c = 56;

	PrintStruct(struktura);



void PrintStruct(T)(ref T s, bool recursive = false, ulong indent = 0) {
	void tabs() {
		for(ulong i = 0; i < indent; i++)
			Log.Print("\t");
	}

	alias FieldNames!(T) fieldNames;

	tabs();
	indent++;

	kprintfln!(T.stringof ~ " ({})")(&s, false);

	foreach(i, _; s.tupleof) {
		static if(is(typeof(s.tupleof[i]) == struct) ||
			(isPointerType!(typeof(s.tupleof[i])) && is(typeof(*s.tupleof[i]) == struct))) {
			tabs();

			if(recursive) {
				putstr(fieldNames[i]);
				putstr(": ");

				static if(isPointerType!(typeof(s.tupleof[i]))) {
					if(s.tupleof[i] is null)
						putstr("(null)\n");
					else {
						putchar('\n');
						printStruct(*s.tupleof[i], true, indent, false);
					}
				} else {
					putchar('\n');
					printStruct(s.tupleof[i], true, indent, false);
				}
			} else {
				static if(isPointerType!(typeof(s.tupleof[i]))) {
					kprintfln!(fieldNames[i] ~ " = {x}")(s.tupleof[i], false);
				} else {
					kprintfln!(fieldType.stringof ~ " " ~ fieldNames[i] ~ " (struct)", false);
				}
			}
		} else {
			tabs();

			static if(isIntType!(typeof(s.tupleof[i]))) {
				kprintfln!(fieldNames[i] ~ " = 0x{x}")(s.tupleof[i], false);
			} else {
				kprintfln!(fieldNames[i] ~ " = {}")(s.tupleof[i], false);
			}
		}
	}
}*/