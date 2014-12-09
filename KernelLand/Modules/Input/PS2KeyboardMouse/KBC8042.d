module Modules.Input.PS2KeyboardMouse.KBC8042;

import Architecture;
import ObjectManager;
import Modules.Input.PS2KeyboardMouse.PS2Mouse;
import Modules.Input.PS2KeyboardMouse.PS2Keyboard;


public static class KBC8042 {
	package static void Initialize() {
		DeviceManager.RequestIRQ(&KeyboardHandler, 1);
		DeviceManager.RequestIRQ(&MouseHandler, 12);

		//some hacks...
		byte tmp = Port.Read!byte(0x61);
		Port.Write!byte(0x61, tmp | 0x80);
		Port.Write!byte(0x61, tmp & 0x7F);
		Port.Read!byte(0x60);
	}

	package static void SetLED(byte state) {
		while (Port.Read!byte(0x64) & 2) {}
		Port.Write!byte(0x60, 0xED);

		while (Port.Read!byte(0x64) & 2) {}
		Port.Write!byte(0x60, state);
	}

	package static void EnableMouse() {
		SendDataAlt(cast(byte)0xA8);

		SendDataAlt(0x20);
		byte status = ReadData();
		status &= ~0x20;
		status |= 0x02;
		SendDataAlt(0x60);
		SendData(status);

		//TODO: SendMouseCommand(0xF6); ???
		// Enable packets
		SendMouseCommand(cast(byte)0xF4);
	}

	private static void SendDataAlt(byte data) {
		int timeout = 100000;
		while (timeout-- && Port.Read!byte(0x64) & 2) {}
		Port.Write!byte(0x64, data);
	}

	private static void SendData(byte data) {
		int timeout = 100000;
		while (timeout-- && Port.Read!byte(0x64) & 2) {}
		Port.Write!byte(0x60, data);
	}

	private static byte ReadData() {
		int timeout = 100000;
		while (timeout-- && !(Port.Read!byte(0x64) & 1)) {}
		return Port.Read!byte(0x60);
	}

	private static void SendMouseCommand(byte cmd) {
		SendDataAlt(cast(byte)0xD4);
		SendData(cmd);
	}

	private static void KeyboardHandler(ref InterruptStack stack) {
		PS2Keyboard.Handler(Port.Read!byte(0x60));
	}

	private static void MouseHandler(ref InterruptStack stack) {
		PS2Mouse.Handler(Port.Read!byte(0x60));
	}
}