module VTManager.VT;

import System.Collections.Generic.All;
import VTManager.VirtualTerminal;
import DeviceManager.Display;


class VT {
static:
	__gshared private List!(VirtualTerminal) mappedVTs;


	bool Init() {
		mappedVTs = new List!(VirtualTerminal)();
		return true;
	}

	void Map(VirtualTerminal vt) {
		Unmap(vt);
		mappedVTs.Add(vt);
	}

	void Unmap(VirtualTerminal vt) {
		mappedVTs.Remove(vt);
		RedrawScreen();
	}

	void UnmapAll() {
		mappedVTs.Clear();
		RedrawScreen();
	}

	void RedrawScreen() {
		Display.Clear();

		foreach (x; mappedVTs)
			x.Redraw();
	}
}