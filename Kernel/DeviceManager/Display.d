module DeviceManager.Display;

import DeviceManager.Device;
import Devices.Display.DisplayProto;
import VTManager.VT;

import System.Collections.Generic.All;
import System.ConsoleColor;
import System.Drawing.All;


struct DisplayMode {
	ushort TextCols, TextRows;
	ushort GraphicWidth, GraphicHeight, GraphicDepth;
	ushort Identifier;
	DisplayProto Dev;
}


class Display {
public:
static:
	__gshared private List!(DisplayMode) modes;
	__gshared private DisplayMode mode;

	@property ushort TextCols()      { return mode.TextCols;      }
	@property ushort TextRows()      { return mode.TextRows;      }
	@property ushort GraphicWidth()  { return mode.GraphicWidth;  }
	@property ushort GraphicHeight() { return mode.GraphicHeight; }
	@property ushort GraphicDepth()  { return mode.GraphicDepth;  }


	bool Init() {
		modes = new List!(DisplayMode)();
		mode.Dev = null;
		return true;
	}

	void Clear() {
		mode.Dev.Clear();
	}

	void PutChar(ushort line, ushort column, wchar c, ConsoleColor color = ConsoleColor.Gray, ConsoleColor bgColor = ConsoleColor.Black) {
		if (line >= mode.TextRows || column >= mode.TextCols)
			return;

		mode.Dev.PutChar(line, column, c, color, bgColor);
	}

	void MoveCursor(ushort line, ushort column) {
		if (line >= mode.TextRows || column >= mode.TextCols)
			return;

		mode.Dev.MoveCursor(line, column);
	}

	void PutPixel(ushort x, ushort y, Color color) {
		if (x >= mode.GraphicWidth || y >= mode.GraphicHeight)
			return;

		mode.Dev.PutPixel(x, y, color);
	}

	Color GetPixel(ushort x, ushort y) {
		if (x >= mode.GraphicWidth || y >= mode.GraphicHeight)
			return Color.Empty;

		return mode.Dev.GetPixel(x, y);
	}

	bool SetMode(DisplayMode mode) {
		if (this.mode.Dev !is null)
			this.mode.Dev.UnsetMode();

		if(mode.Dev.SetMode(mode)) {
			this.mode = mode;
			VT.RedrawScreen();
			return true;
		}
		return false;
	}

	void ScanModes() {
		modes.Clear();
		auto d = Device.GetDevsByType(DeviceType.Display);

		foreach (x; d) {
			DisplayMode[] dm = (cast(DisplayProto)x).GetModes();

			foreach (y; dm)
				modes.Add(y);
		}

		delete d;
	}
}