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
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module Modules.Input.PS2KeyboardMouse.PS2Keyboard;

import ObjectManager;


static class PS2Keyboard {
	private __gshared bool _up;
	private __gshared int _layer;


	static ModuleResult Initialize(string[] args) {
		//TODO: in keyboard module call function "create instance"
		//gPS2Kb_Info = Keyboard_CreateInstance(KEYSYM_RIGHTGUI, "PS2Keyboard");
		return ModuleResult.Successful;
	}

	package static void Handler(byte code) {
		if (code == 0xFA)
			return;

		if (code == 0xE0) {
			_layer = 1;
			return;
		}

		if (code == 0xE1) {
			_layer = 2;
			return;
		}

		if (code & 0x80) {
			code &= 0x7F;
			_up = true;
		}

		//TODO: call Keyboard module... + some shit
	}

	package static void UpdateLED() {
		import Core;
		Log.WriteLine("TODO: Fix Keyboard LEDs..."); //TODO
	}
}