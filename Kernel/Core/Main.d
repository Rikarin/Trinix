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
import DeviceManager.Keyboard;

import VTManager.VT;

import Devices.Keyboard.PS2Keyboard;
import Devices.Display.VGATextOutput;

/++
Framework:
	BitArray
	Mutex
	-Wchar atd.
	Color - FromKnownColor name, ToUpper...
	convert - prerobit na vlastny string bez alloc

System:
	PhysMem -> BitArray
	MP
	VTManager
	dorobit IDT
	dorobit ScanModes v Display
	VirtualTerminal SC a doladit Read()

	Dorobit heap & delete!!
	timer APIC
	VT Manager!!!
	Az potom VFS a syscall mgr
	devvice - register device...
	dorobit string
	Panic - vypis Rx registrov, inak vsetko O.K.
	Dorobit random
	dorobit pipeDev
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
	//Memory.KernelHeap.Create(cast(ulong)PageAllocator.AllocPage(), Heap.MIN_SIZE + 0x1000000, 0x10000, Paging.KernelPaging);
	//PageAllocator.IsInit = true;
	Log.Result(false);

	Log.Print("Initializing Multiprocessor configuration");
	Log.Result(Multiprocessor.Init());

	Log.Print("Starting multiple cores");
	Log.Result(true);
	Multiprocessor.BootCores(); 


//==================== MANAGERS ====================
	Log.Print("Initializing device manger");
	Log.Result(Device.Init());
	
	Log.Print("Initializing keyboard manger");
	Log.Result(Keyboard.Init());

	Log.Print("Initializing display manger");
	Log.Result(Display.Init());

	Log.Print("Initializing VT manager");
	Log.Result(VT.Init());
	
//==================== DEVICES ====================
	//Log.Print("Initializing timer ticks = 100Hz");
	//new Timer(100);
	//Log.Result(true);

	Log.Print("Initializing PS/2 keyboard driver");
	new PS2Keyboard();
	Log.Result(true);

	Log.Print("Initializing VGA text output driver");
	VGATextOutput textOutput = new VGATextOutput();
	Log.Result(true);

	Log.Print("Init complete, starting terminal");
	Log.Result(false);


	/*
		new FSNode...
		Directory.AddNode(FSNode)...

		or

		Directory.CreateFile/CreateDirectory = ret Dirnode or filenode

		FSNode nulld = new NullDev();
		DirectoryNode.AddChildNode(nulld);

	*/


	//setup display mode
	//Display.SetMode(textOutput.GetModes()[0]);

	/*import System.Collections.BitArray;
	BitArray ba = new BitArray(0x100000);
	foreach (i; 0 .. 100) {
		long idx = ba.FirstFreeBit();

		import System.Convert;
		Log.PrintSP("\nid: " ~ Convert.ToString(idx));
		ba[idx] = true;
	}*/

	//assert("testik");

	while (true) {}
}




/* I don't know wat is it

__gshared const ulong FSBASE_MSR = 0xc000_0100;
__gshared const ulong GSBASE_MSR = 0xc000_0101;


void Init() {
	import Architectures.Port;

	const ulong STAR_MSR = 0xc000_0081;
	const ulong LSTAR_MSR = 0xc000_0082;
	const ulong SFMASK_MSR = 0xc000_0084;

	const ulong STAR = 0x003b_0010_0000_0000;
	const uint STARHI = STAR >> 32;
	const uint STARLO = STAR & 0xFFFF_FFFF;

	ulong addy = cast(ulong)&SyscallHandler;

	Port.WriteMSR(LSTAR_MSR, addy);
	Port.WriteMSR(STAR_MSR, STAR);
	Port.WriteMSR(SFMASK_MSR, 0);

	PhysicalAddress stackPtr = PageAllocator.AllocPage();
	ulong syscallStack = cast(ulong)stackPtr + 4096;

	asm {
		push RAX;
		mov RAX, 3;
		shl RAX, 3;
		mov GS, AX;
		pop RAX;
	}

	Port.WriteMSR(GSBASE_MSR, syscallStack);

}

void SyscallHandler() {
	asm {
		naked;
		hlt;

		// save regs used by rdmsr
		mov R8, RAX;
		mov R9, RCX;
		mov R10, RDX;

		// zero RAX higher bits, cuz rdmsr doc doesn't mention if it zeros it
		mov RAX, 0;

		// read the CPU stack address to RDX
		mov ECX, GSBASE_MSR;
		rdmsr;

		//shl RDX, 32;
		or RDX, RAX;

		// restore saved registers and stick new stack addr in R8, old stack addr in R9
		mov RAX, R8;
		mov RCX, R9;

		mov R8, RDX;
		mov RDX, R10;
		mov R9, RSP;

		// set new stack
		mov RSP, R8;

		// save old stack info where we can get it
		push R9;
		push RBP;

		// vars used by syscall
		push RCX;
		push R11;
		push RAX;

		// call dispatcher
		call SyscallDispatcher;

		pop RAX;
		pop R11;
		pop RCX;

		// restore stack foo
		pop RBP;
		pop R9;
		mov RSP, R9;

		sysret;
	}
}

extern(C) void SyscallDispatcher(ulong ID, void* ret, void* params) {
	Log.Print("test");
	while (true) {}
// RCX holds the return address for the system call, which is useful
// for certain system calls (such as fork)

//void* stackPtr;
//asm {
// "movq %%rsp, %%rax" ::: "rax";
// "movq %%rax, %0" :: "o" stackPtr : "rax";
//}//
//kprintfln!("Syscall: ID = 0x{x}, ret = 0x{x}, params = 0x{x}")(ID, ret, params);
//mixin(MakeSyscallDispatchList!());
}*/