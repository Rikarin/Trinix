module Modules.Input.PS2KeyboardMouse.PS2Keyboard;

import ObjectManager;


public static class PS2Keyboard {
	private __gshared bool _up;
	private __gshared int _layer;


	public static ModuleResult Initialize(string[] args) {
		//TODO: in keyboard module call function "create instance"
		//gPS2Kb_Info = Keyboard_CreateInstance(KEYSYM_RIGHTGUI, "PS2Keyboard");
		return ModuleResult.Sucessful;
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