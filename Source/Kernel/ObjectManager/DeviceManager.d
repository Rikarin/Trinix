module ObjectManager.DeviceManager;

import VFSManager;
import Architecture;


public struct InterruptStack {
align(1):
	ulong DS, ES, FS, GS;
	ulong R15, R14, R13, R12, R11, R10, R9, R8;
	ulong RBP, RDI, RSI, RDX, RCX, RBX, RAX;
	ulong IntNumber, ErrorCode;
	ulong RIP, CS, Flags, RSP, SS;
}


public abstract final class DeviceManager {
	private __gshared void function(ref InterruptStack stack) _handlers[48];
	public __gshared DirectoryNode DevFS;

	public static void RequestIRQ(void function(ref InterruptStack) handle, int intNumber) { //TODO: pass instance of class against func ref
		if (intNumber < 16)
			_handlers[intNumber + 32] = handle;
	}

	public static void RequestISR(void function(ref InterruptStack) handle, int intNumber) { //TODO: pass instance of class against func ref
		if (intNumber < 32)
			_handlers[intNumber] = handle;
	}

	public static void Handler(ref InterruptStack stack) {
		if (stack.IntNumber < 48) {
			if (_handlers[stack.IntNumber] !is null)
				_handlers[stack.IntNumber](stack);
		}
	}

	public static void EOI(int irqNumber) {
		if (irqNumber >= 8)
			Port.Write!byte(0xA0, 0x20);
		
		Port.Write!byte(0x20, 0x20);
	}
}