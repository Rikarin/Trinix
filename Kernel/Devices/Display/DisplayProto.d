module Devices.Display.DisplayProto;

import DeviceManager.Display;
import Devices.DeviceProto;

import System.Drawing.All;
import System.ConsoleColor;


abstract class DisplayProto : DeviceProto {
	~this() {}

	 DisplayMode[] GetModes();
	 bool SetMode(DisplayMode mode);
	 void UnsetMode() {}

	 void PutChar(ushort line, ushort column, wchar c, ConsoleColor color, ConsoleColor bgColor);
	 void GetChar(ushort line, ushort column, out wchar c, out ConsoleColor color, out ConsoleColor bgColor);
	 void MoveCursor(ushort line, ushort column);
	 void Clear();

	 void PutPixel(ushort line, ushort column, Color color) { }
	 Color GetPixel(ushort line, ushort column) { return Color.Empty; }
}