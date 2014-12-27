/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * http://bit.ly/1wIYh3A and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module Modules.Input.PS2KeyboardMouse.KBC8042;

import Architecture;
import ObjectManager;
import Modules.Input.PS2KeyboardMouse.PS2Mouse;
import Modules.Input.PS2KeyboardMouse.PS2Keyboard;


static class KBC8042 {
	package static void Initialize() {
		DeviceManager.RequestIRQ(&KeyboardHandler, 1);
		DeviceManager.RequestIRQ(&MouseHandler, 12);

		//some hacks...
		byte tmp = Port.Read(0x61);
		Port.Write(0x61, tmp | 0x80);
		Port.Write(0x61, tmp & 0x7F);
		Port.Read(0x60);
	}

	package static void SetLED(byte state) {
		while (Port.Read(0x64) & 2) {}
		Port.Write(0x60, 0xED);

		while (Port.Read(0x64) & 2) {}
		Port.Write(0x60, state);
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
		while (timeout-- && Port.Read(0x64) & 2) {}
		Port.Write(0x64, data);
	}

	private static void SendData(byte data) {
		int timeout = 100000;
		while (timeout-- && Port.Read(0x64) & 2) {}
		Port.Write(0x60, data);
	}

	private static byte ReadData() {
		int timeout = 100000;
		while (timeout-- && !(Port.Read(0x64) & 1)) {}
		return Port.Read(0x60);
	}

	private static void SendMouseCommand(byte cmd) {
		SendDataAlt(cast(byte)0xD4);
		SendData(cmd);
	}

	private static void KeyboardHandler(ref InterruptStack stack) {
		PS2Keyboard.Handler(Port.Read(0x60));
	}

	private static void MouseHandler(ref InterruptStack stack) {
		PS2Mouse.Handler(Port.Read(0x60));
	}
}