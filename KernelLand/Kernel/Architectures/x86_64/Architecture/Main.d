module Architecture.Main;

import Core;
import Architecture;
import ObjectManager;


abstract final class Arch {
	static void Main(uint magic, void* info) {
		Log.WriteJSON("{");
		Log.WriteJSON("name", "multiboot2");
		Log.WriteJSON("value", "{");
		Multiboot.ParseHeader(magic, info);
		Log.WriteJSON("}");
		Log.WriteJSON("}");

		Log.WriteJSON("{");
		Log.WriteJSON("name", "CPU");
		Log.WriteJSON("value", "[");
		CPU.Initialize();
		CPU.Install();
		Log.WriteJSON("]");
		Log.WriteJSON("}");
	}
}