module Modules.Input.PS2KeyboardMouse.PS2Mouse;

import ObjectManager;


public static class PS2Mouse {
	private enum Sensitivity = 1;
	package __gshared void function() EnableMouse;

	private __gshared byte[4] _bytes;
	private __gshared int _cycle;

	public static ModuleResult Initialize(string[] args) {
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