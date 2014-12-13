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

module Modules.Input.PS2KeyboardMouse.PS2Mouse;

import ObjectManager;


static class PS2Mouse {
	private enum Sensitivity = 1;
	package __gshared void function() EnableMouse;

	private __gshared byte[4] _bytes;
	private __gshared int _cycle;

	static ModuleResult Initialize(string[] args) {
		//TODO: in mouse module call function "create instance"
		//gpPS2Mouse_Handle = Mouse_Register("PS2Mouse", NUM_AXIES, NUM_BUTTONS);
		EnableMouse();

		return ModuleResult.Sucessful;
	}

	package static void Handler(byte code) {
		_bytes[_cycle] = code;

		if (!_cycle && !(_bytes[0] & 0x08))
			return;

		if (++_cycle < 3)
			return;

		_cycle = 0;
		if (_bytes[0] & 0xC0)
			return;
			
		if (_bytes[0] & 0x10)
			_bytes[1] = cast(byte)-(256 - _bytes[1]);
			
		if (_bytes[0] & 0x10)
			_bytes[2] = cast(byte)-(256 - _bytes[2]);
		_bytes[2] = -_bytes[2];

		byte[2] b;
		b[0] = _bytes[1] * Sensitivity;
		b[1] = _bytes[2] * Sensitivity;

		// Apply scaling
		// TODO: Apply a form of curve to the mouse movement (dx*log(dx), dx^k?)
		// TODO: Independent sensitivities?
		// TODO: Disable acceleration via a flag?

		// TODO: Scroll wheel?	
		//Mouse_HandleEvent(gpPS2Mouse_Handle, (flags & 7), d_accel);
	}
}